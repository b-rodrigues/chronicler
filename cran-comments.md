# Submission of version 0.3.0

No notes, no errors nor warnings on win-devel nor win-release.
Only on win-oldrel, 2 NOTES:

>Found the following (possibly) invalid URLs:
>
>  URL: https://x.com/armcn_/status/1511705262935011330?s=20&t=UfwIjsqyOX7-UbTMBHOCuw
>
>    From: inst/doc/a-non-mathematician-s-introduction-to-monads.html
>
>    Status: 403
>
>    Message: Forbidden
>
>  URL: https://x.com/putosaure
>
>    From: README.md
>
>    Status: 403
>
>    Message: Forbidden

but these links do exist and are accessible.

Also tested as well on R-hub, no notes, nor errors on other platforms.

# Submission of version 0.2.2

Minor update, to take tidyselect v 1.2.1 into account: two unit tests
didn't pass anymore due to his update, so this has been fixed as requested
by CRAN team before 2024-03-26.

Running checks on Rhub resulted in notes, but I believe it's not
relevant for releasing on CRAN.

## Test environments

## R CMD check results

- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)


> On windows-x86_64-devel (r-devel)
  NOTES:
  * checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    ''NULL''
  * checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

> RHUB_PLATFORM=linux-x86_64-fedora-clang
  NOTES:
  * checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

> RHUB_PLATFORM=linux-x86_64-ubuntu-gcc
  NOTES:
  * checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found

# Submission of version 0.2.1

Minor update, to take dplyr v 1.1.0 into account.

Running checks on Rhub resulted in two note, but I believe it's not 
relevant for releasing on CRAN.

Changed url to canonical form in Readme.md.

## Test environments

## R CMD check results

- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)


> On windows-x86_64-devel (r-devel)
  checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
    
> fedora-clang-devel (r-devel)
  checking HTML version of manual ... NOTE
  Skipping checking HTML validation: no command 'tidy' found


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
