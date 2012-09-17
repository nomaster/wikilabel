# Wikilabel

A simple script to print labels for resources and books in the Chaosdorf Wiki.

## Installation

1. Install ruby
2. Use rubygems to install Bundler: `gem install bundler`
3. Change into the Wikilabel source directory
4. Use Bundler to install dependencies: `bundle install`

## Invocation

In the Wikilabel source directory, you can run the script to generate PDF files
to be printed later on.

    $ ruby wikilabel.rb [Name of the Resource]

For example `ruby wikilabel.rb Printer` will create a file `printer.pdf`
