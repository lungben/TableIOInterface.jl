module TableIOInterface

export get_file_type, get_example_code, is_extension_supported

## definition of file formats and extensions

abstract type AbstractFormat end

struct CSVFormat <: AbstractFormat end
struct ZippedFormat <: AbstractFormat end
struct JDFFormat <: AbstractFormat end
struct ParquetFormat <: AbstractFormat end
struct ExcelFormat <: AbstractFormat end
struct SQLiteFormat <: AbstractFormat end
struct StataFormat <: AbstractFormat end
struct SPSSFormat <: AbstractFormat end
struct SASFormat <: AbstractFormat end
struct JSONFormat <: AbstractFormat end
struct ArrowFormat <: AbstractFormat end
struct HDF5Format <: AbstractFormat end

# data base only formats - not completely integrated yet
struct PostgresFormat <: AbstractFormat end

# define if copy of columns is required when converting Tables.jl interface to DataFrame
require_copycols(::AbstractFormat) = false
require_copycols(::JSONFormat) = true

# mapping of file extensions to table file formats
# multiple extensions can be mapped to the same format
const FILE_EXTENSIONS = Dict{String, DataType}(
    "zip" => ZippedFormat,
    "csv" => CSVFormat,
    "jdf" => JDFFormat,
    "parquet" => ParquetFormat,
    "xlsx" => ExcelFormat,
    "xlsm" => ExcelFormat,
    "db" => SQLiteFormat,
    "sqlite" => SQLiteFormat,
    "sqlite3" => SQLiteFormat,
    "dta" => StataFormat,
    "sav" => SPSSFormat,
    "sas7bdat" => SASFormat,
    "json" => JSONFormat,
    "arrow" => ArrowFormat,
    "hdf" => HDF5Format,
    "hdf5" => HDF5Format,
)

_get_file_extension(filename:: AbstractString) = lowercase(splitext(filename)[2][2:end])

get_file_type(filename:: AbstractString) = FILE_EXTENSIONS[_get_file_extension(filename)]()

is_extension_supported(extension:: AbstractString) = lowercase(extension) ∈ keys(FILE_EXTENSIONS)

const import_table_io = "import TableIO"
const import_dataframes = "import DataFrames"

function get_example_code(t::T, directory:: AbstractString, filename:: AbstractString) where {T <: AbstractFormat}
    """
    df_$(_get_varname(filename)) = let
        $import_table_io
        $import_dataframes
        DataFrames.DataFrame(TableIO.read_table($(_get_path_code(directory, filename))); copycols=$(require_copycols(t)))
    end"""
end

function get_example_code(t::ExcelFormat, directory:: AbstractString, filename:: AbstractString)
    """
    df_$(_get_varname(filename)) = let
        $import_table_io
        $import_dataframes
        DataFrames.DataFrame(TableIO.read_table($(_get_path_code(directory, filename)),
            # "Sheet1", # uncomment this to specify the sheet name to be imported
            ); copycols=$(require_copycols(t)))
    end"""
end

function get_example_code(t::SQLiteFormat, directory:: AbstractString, filename:: AbstractString)
    """
    df_$(_get_varname(filename)) = let
        $import_table_io
        $import_dataframes
        DataFrames.DataFrame(TableIO.read_table($(_get_path_code(directory, filename)),
            "tablename", # define the table name here
            ); copycols=$(require_copycols(t)))
    end"""
end

function get_example_code(t::ZippedFormat, directory:: AbstractString, filename:: AbstractString)
    """
    df_$(_get_varname(filename)) = let
        $import_table_io
        $import_dataframes
        DataFrames.DataFrame(TableIO.read_table($(_get_path_code(directory, filename)),
            # "filename_in_archive", # uncomment this to specify a specific file name in the archive
            ); copycols=$(require_copycols(t)))
    end"""
end

function get_example_code(t::HDF5Format, directory:: AbstractString, filename:: AbstractString)
    """
    df_$(_get_varname(filename)) = let
        $import_table_io
        $import_dataframes
        DataFrames.DataFrame(TableIO.read_table($(_get_path_code(directory, filename)),
            "/data", # define the key of the dataset in the HDF file here
            ); copycols=$(require_copycols(t)))
    end"""
end

# `directory` is not used anymore because it corresponds to the notebook directory when inserting the data,
# not the current notebook directory. 
_get_path_code(directory, filename) = """joinpath(split(@__FILE__, '#')[1] * ".assets", "$filename")"""

_get_varname(filename) = replace(filename, r"[\"\-,\.#@!\%\s+\;()\$&*\[\]\{\}'^]" => "_")

get_example_code(directory:: AbstractString, filename:: AbstractString, args...; kwargs...) = get_example_code(get_file_type(filename), directory, filename, args...; kwargs...)
end
