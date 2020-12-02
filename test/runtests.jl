using TableIOInterface
using Test

@testset "TableIOInterface.jl" begin

    fnames = ["test.csv", "test.jdf", "test.parquet", "test.arrow", "test.xlsx", "test.json", 
                "test.zip", "test.sqlite", "test.hdf"]

    @testset "File type ID" begin
        
        expected_file_types = [TableIOInterface.CSVFormat, TableIOInterface.JDFFormat, TableIOInterface.ParquetFormat,
        TableIOInterface.ArrowFormat, TableIOInterface.ExcelFormat, TableIOInterface.JSONFormat,
        TableIOInterface.ZippedFormat, TableIOInterface.SQLiteFormat, TableIOInterface.HDF5Format]

        for (i, fname) ∈ enumerate(fnames)
            file_type = get_file_type(fname)
            @test file_type == expected_file_types[i]()
        end
    end

    @testset "Sample code generation" begin
        expected_sample_code = [
            """df_test_csv = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.csv")); copycols=false)
            end""",

            """df_test_jdf = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.jdf")); copycols=false)
            end""",
            
            """df_test_parquet = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.parquet")); copycols=false)
            end""",    

            """df_test_arrow = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.arrow")); copycols=false)
            end""",
            
            """df_test_xlsx = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.xlsx"),
                    # "Sheet1", # uncomment this to specify the sheet name to be imported
                    ); copycols=false)
            end""",

            """df_test_json = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.json")); copycols=true)
            end""",
            
            """df_test_zip = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.zip"),
                    # "filename_in_archive", # uncomment this to specify a specific file name in the archive
                    ); copycols=false)
            end""",
            
            """df_test_sqlite = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.sqlite"),
                    "tablename", # define the table name here
                    ); copycols=false)
            end""",

            """df_test_hdf = let
                import TableIO
                import DataFrames
                DataFrames.DataFrame(TableIO.read_table(joinpath(split(@__FILE__, '#')[1] * ".assets", "test.hdf"),
                    "/data", # define the key of the dataset in the HDF file here
                    ); copycols=false)
            end""",

        ]

        for (i, fname) ∈ enumerate(fnames)
            sample_code = get_example_code("my_notebook.jl.assets", fname)
            @test sample_code == expected_sample_code[i]
            println(sample_code)
        end

        @test is_extension_supported("csv") && !is_extension_supported("foo") && is_extension_supported("xlsx")


    end

end
