[![Build Status](https://travis-ci.com/lungben/TableIO.jl.svg?branch=master)](https://travis-ci.com/lungben/TableIOInterface.jl)
[![codecov](https://codecov.io/gh/lungben/TableIO.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lungben/TableIOInterface.jl)

# TableIOInterface

Tiny package for determination of tabular file formats based on file extensions.

It is intended to be the base both for TableIO.jl and for the Pluto.jl tabular data import functionality.

## Usage

    get_file_type("test.csv") # gives TableIOInterface.CSVFormat()
    get_file_type("test.zip") # gives TableIOInterface.ZippedFormat()

    is_extension_supported("csv") # gives true
    is_extension_supported("foo") # gives false

etc.
