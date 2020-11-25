# TableIOInterface

Tiny package for determination of tabular file formats based on file extensions.

It is intended to be the base both for TableIO.jl and for the Pluto.jl tabular data import functionality.

## Usage

    get_file_type("test.csv") # gives TableIOInterface.CSVFormat()
    get_file_type("test.zip") # gives TableIOInterface.ZippedFormat()

etc.
