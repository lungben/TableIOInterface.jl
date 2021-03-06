module TableIOInterface

export get_file_type, get_example_code, is_extension_supported, multiple_tables

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
struct JLD2Format <: AbstractFormat end
struct JuliaFormat <: AbstractFormat end

# data base only formats - not completely integrated yet
struct PostgresFormat <: AbstractFormat end

# define if copy of columns is required when converting Tables.jl interface to DataFrame
require_copycols(::AbstractFormat) = false
require_copycols(::JSONFormat) = true

# specify if mutliple tables could be inside a single file
multiple_tables(::AbstractFormat) = false

multiple_tables(::ZippedFormat) = true
multiple_tables(::ExcelFormat) = true
multiple_tables(::SQLiteFormat) = true
multiple_tables(::HDF5Format) = true
multiple_tables(::JLD2Format) = true
multiple_tables(::PostgresFormat) = true
multiple_tables(::JuliaFormat) = true

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
    "jld2" => JLD2Format,
    "jl" => JuliaFormat,
)

_get_file_extension(filename:: AbstractString) = lowercase(splitext(filename)[2][2:end])

get_file_type(filename:: AbstractString) = FILE_EXTENSIONS[_get_file_extension(filename)]()

is_extension_supported(extension:: AbstractString) = lowercase(extension) ∈ keys(FILE_EXTENSIONS)

const import_table_io = "import TableIO"
const import_dataframes = "import DataFrames"

# `directory` is not used anymore because it corresponds to the notebook directory when inserting the data,
# not the current notebook directory. 
get_example_code(t::T, directory:: AbstractString, filename:: AbstractString) where {T <: AbstractFormat} = get_example_code(t, filename)

function get_example_code(t::T, filename:: AbstractString) where {T <: AbstractFormat}
    if multiple_tables(t)
        """
        df_$(_get_varname(filename)) = let
            $import_table_io
            $import_dataframes
            # table_list = TableIO.list_tables($(_get_path_code(filename))) # uncomment to get a list of all tables in this file
            DataFrames.DataFrame(TableIO.read_table($(_get_path_code(filename)),
                # "tablename", # define the table name here, if not defined the alphabetically first table is loaded
                ); copycols=$(require_copycols(t)))
        end"""
    else
        """
        df_$(_get_varname(filename)) = let
            $import_table_io
            $import_dataframes
            DataFrames.DataFrame(TableIO.read_table($(_get_path_code(filename))); copycols=$(require_copycols(t)))
        end"""
    end
end

_get_path_code(filename) = """joinpath(split(@__FILE__, '#')[1] * ".assets", "$filename")"""

_get_varname(filename) = replace(filename, r"[\"\-,\.#@!\%\s+\;()\$&*\[\]\{\}'^]" => "_")

get_example_code(directory:: AbstractString, filename:: AbstractString, args...; kwargs...) = get_example_code(get_file_type(filename), directory, filename, args...; kwargs...)
end
