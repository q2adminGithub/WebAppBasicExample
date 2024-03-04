library(jsonlite)
library(rlang)

# stand-alone script to transform the .rda files containing the input tables into a file used for initial load during execution of init.sql
# run this from a R installation on Linux (uses shell commands echo and cat)
# any delimiter different from '|' must also be taken into account in the COPY statement in init.sql

convertRDAtoJSON <- function(inputDirectory, outputDirectory, outputFilename, delimiter){

    input_file_names <- base::list.files(
        path = inputDirectory,
        pattern = ".rda",
        full.names = TRUE,
        recursive = TRUE
    )

    ldf <- lapply(input_file_names, function(x){eval(rlang::sym(load(x)))})
    varnames <- sapply(input_file_names, load, USE.NAMES = FALSE)
    names(ldf) <- varnames

    if (length(ldf) > 0){

        tmpDir <- paste0(outputDirectory, '/tmp/')
        if (dir.exists(tmpDir) == FALSE){
            dir.create(tmpDir)
        }
        finalOutput <- paste0(outputDirectory, '/', outputFilename)
        x <- c()
        for (dfname in ls(ldf)) {
            if (is.data.frame(ldf[[dfname]]) == FALSE){
                system(paste0('cat > ', finalOutput)) # creating a new empty file
                unlink(tmpDir, recursive=TRUE, force=TRUE)
                return(paste0('ERROR: the variable ', dfname, ' is not a data.frame ... creating empty output file'))
            }
            jsonstring <- jsonlite::toJSON(ldf[[dfname]])

            if (grepl(delimiter, jsonstring, fixed = TRUE)){
                system(paste0('cat > ', finalOutput)) # creating a new empty file
                unlink(tmpDir, recursive=TRUE, force=TRUE)
                return(paste0('ERROR: the dataframe ', dfname, ' contains the delimiter ', delimiter, ' ... creating empty output file'))
            }
            outfilename <- paste0(tmpDir, dfname, '.txt')
            newoutfilename <- paste0(tmpDir, dfname, '_modified.txt')
            x <- append(x, newoutfilename)
            jsonlite::write_json(ldf[[dfname]], outfilename)
            system(paste0('{ echo -n "',dfname, delimiter,'"; cat ',outfilename,'; } >',newoutfilename)) # inserting the entry for name column with | as delimiter, see https://stackoverflow.com/a/26580151
        }
        allfiles <- paste(x, collapse=' ')
        system(paste0('cat ',allfiles,' > ', finalOutput))
        ret <- paste0(outputFilename, ' successfully created in ', outputDirectory)
        unlink(tmpDir, recursive=TRUE, force=TRUE)
    } else {
        ret <- paste0('ERROR: there are no input .rda files present ... creating empty output file')
        system(paste0('cat > ', finalOutput)) # creating a new empty file
    }
    return(ret)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 4) {
    stop("must provide 4 argument: inputDirectory outputDirectory, outputFilename, delimiter", call. = FALSE)
} else {
    ret <- convertRDAtoJSON(args[1], args[2], args[3], args[4])
}
print(ret)