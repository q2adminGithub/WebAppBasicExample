library(jsonlite)
library(rlang)

# stand-alone script to transform the .rda files containing the input tables into a file used for initial load during execution of init.sql
# run this from a R installation on Linux (uses shell commands echo and cat)

input_file_names <- base::list.files(
    path = "../assets/inputdata",
    pattern = ".rda",
    full.names = TRUE,
    recursive = TRUE
)

ldf <- lapply(input_file_names, function(x){eval(rlang::sym(load(x)))})
varnames <- sapply(input_file_names, load, USE.NAMES = FALSE)
names(ldf) <- varnames

if (length(ldf) > 0){

    tmpDir <- "../assets/tmp/"
    if (dir.exists(tmpDir) == FALSE){
        dir.create(tmpDir)
    }

    x <- c()
    delimiter <- '|' # any change here must also be taken into account in the COPY statement in init.sql
    delimiterPresent <- ''
    for (dfname in ls(ldf)) {
        jsonstring <- jsonlite::toJSON(ldf[[dfname]])

        if (grepl(delimiter, jsonstring, fixed = TRUE)){
            delimiterPresent <- dfname
        }
        outfilename <- paste0(tmpDir, dfname, '.txt')
        newoutfilename <- paste0(tmpDir, dfname, '_modified.txt')
        x <- append(x, newoutfilename)
        jsonlite::write_json(ldf[[dfname]], outfilename)

        system(paste0('{ echo -n "',dfname, delimiter,'"; cat ',outfilename,'; } >',newoutfilename)) # inserting the entry for name column with | as delimiter, see https://stackoverflow.com/a/26580151
    }
    if (nchar(delimiterPresent) == 0){
        allfiles <- paste(x, collapse=' ')
        system(paste0('cat ',allfiles,' > ../assets/inputdata/inputdata.txt'))
        print('inputdata.txt successfully created in ../assets/inputdata')
    } else {
        system(paste0('cat > ../assets/inputdata/inputdata.txt')) # creating a new empty file
        print(paste0('ERROR: the delimiter ',delimiter,' is present in the input data for variable ',delimiterPresent,' ... creating empty inputdata.txt in ../assets/inputdata'))
    }
    unlink(tmpDir, recursive=TRUE, force=TRUE)
} else {
    print(paste0('ERROR: there are no input .rda files present ... creating empty inputdata.txt in ../assets/inputdata'))
    system(paste0('cat > ../assets/inputdata/inputdata.txt')) # creating a new empty file
}