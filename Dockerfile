FROM rocker/r-ver:3.6.3

# Installing dependencies
RUN R -q -e 'install.packages("dplyr", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("magrittr", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("htmlTable", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("openxlsx", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("tidyr", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("stringr", repo="http://cran.rstudio.com/")'
RUN R -q -e 'install.packages("testthat", repo="http://cran.rstudio.com/")'

# Copying compareDF
RUN echo "Copying res-vimana master to install deps"
COPY . /home/compareDF/
WORKDIR /home/compareDF

RUN R CMD INSTALL .

# Running Tests
CMD ["R", "--vanilla", "-e",  "testthat::test_dir('tests/testthat/', stop_on_failure = TRUE)"]