# Submission of version 0.2.1

Minor update, to take dplyr v 1.1.0.

Running checks on Rhub resulted in one note, but I believe it's not 
relevant for releasing on CRAN.

## Test environments

## R CMD check results

- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)


> On windows-x86_64-devel (r-devel)
  checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

0 errors v | 0 warnings v | 1 notes x

# Resubmission
This is a resubmission. In this version I have:

* Responded to comments by Gregor Seyer by adding \value tags to:
      is_chronicle.Rd
      print.chronicle.Rd
      
  I have also include more details to the print method by describing
  the structure of 'chronicle' objects
  
* The description text now only uses undirected quotation marks.

Running checks on Rhub resulted in two notes, but I believe they are not
relevant for releasing on CRAN.

## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results
> On windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release), fedora-clang-devel (r-devel)
  checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Bruno Rodrigues <bruno@brodrigues.co>'
  
  New submission

> On windows-x86_64-devel (r-devel)
  checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

0 errors v | 0 warnings v | 2 notes x
