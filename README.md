
# compareDF

[![Travis-CI Build Status](https://travis-ci.org/alexsanjoseph/compareDF.svg?branch=master)](https://travis-ci.org/alexsanjoseph/compareDF)
[![codecov.io](http://codecov.io/github/alexsanjoseph/compareDF/coverage.svg?branch=master)](http://codecov.io/github/alexsanjoseph/compareDF?branch=master)

# Introduction

This package shows what has changed between two data frames that have the same columnar
structure. Such comparison is useful in many cases, for example when you expect only minor 
changes in the data across two data sets such as:

* Variation of a dataset across different time periods for the same grouping
* Variation of values for different algorithms, etc.

# Usage

The package has a single function, `compare_df`. It takes in two data frames, and one or 
more grouping variables and does a comparison between the the two. In addition you can 
sepcificy columns to ignore, decide how many rows of changes to be displayed in the case 
of the HTML output, and decide what tolerance you want to provide to detect change.

# Basic Example

Let's take the case of a teacher who wants to compare the marks and grades of students across
two years, 2010 and 2011. The data is stored in tabular format.


```r
data("results_2010", "results_2011")
print(results_2010)
```

```
##    Division Student Maths Physics Chem Discipline PE Art
## 1         A   Isaac    90      84   91          B  B  34
## 2         A  Akshay    85      92   91          B  B  36
## 3         A Vishwas    93      93   92          A  B  21
## 4         A   Rohit    95      92   71          C  B  37
## 5         A    Venu    99      92   82          A  E  78
## 6         A  Ananth    99      81   91          B  A  24
## 7         B    Jojy    67      92   81          B  A  27
## 8         B   Bulla    84      73   81          C  A  68
## 9         B   Katti    90      95   99          C  B  49
## 10        B Dhakkan    78      96   71          C  C  39
## 11        B   Macho    90      82   81         A+  D  30
## 12        B  Mugger    95      71   94          A  C  26
```

```r
print(results_2011)
```

```
##    Division Student Maths Physics Chem Discipline PE Art
## 1         A   Isaac    90      84   91          A  B  34
## 2         A  Akshay    85      92   91          A  B  36
## 3         A Vishwas    82      93   92          B  B  21
## 4         A   Rohit    94      92   71          D  B  37
## 5         A    Venu   100      92   82          A  E  78
## 6         A  Ananth    78      81   91          B  A  24
## 7         B    Jojy    99      92   81          B  A  27
## 8         B   Bulla    97      73   81          C  A  68
## 9         B   Katti    78      95   99          C  B  49
## 10        B   Rohit    79      96   71          C  C  39
## 11        B   Macho    90      82   81         A+  D  30
## 12        B  Vikram    99      79   98          A  B  99
## 13        B DIkChik    91      71   84          E  C  99
```

The data shows the performance of students in two divisions, A and B for two years. Some subjects
like Maths, Physics, Chemistry and Art are given scores while others like Discipline and PE are 
given grades. 

It is possible that there are students of the same name in two divisions, for example, there is 
a Rohit in both the divisions in 2011.

It is also possible that some students have dropped out, or added new across the two years. 
Eg: - Mugger and Dhakkan dropped out while Vikram and Dikchik where added in the Division B

## Basic Comparison
Now let's compare the performance of the students across the years. The grouping variables is the
_Student_ columns. We will ignore the _Division_ columns and assume that the 


```r
library(compareDF)
ctable_student = compare_df(results_2011, results_2010, c("Student"))
```

```
## Creating comparison table...
```

```
## Loading required namespace: htmlTable
```

```
## Creating HTML table for first 100 rows
```

```r
ctable_student$comparison_df
```

```
##    Student chng_type Division Maths Physics Chem Discipline PE Art
## 1   Akshay         +        A    85      92   91          A  B  36
## 2   Akshay         -        A    85      92   91          B  B  36
## 3   Ananth         +        A    78      81   91          B  A  24
## 4   Ananth         -        A    99      81   91          B  A  24
## 5    Bulla         +        B    97      73   81          C  A  68
## 6    Bulla         -        B    84      73   81          C  A  68
## 7  Dhakkan         -        B    78      96   71          C  C  39
## 8    Isaac         +        A    90      84   91          A  B  34
## 9    Isaac         -        A    90      84   91          B  B  34
## 10    Jojy         +        B    99      92   81          B  A  27
## 11    Jojy         -        B    67      92   81          B  A  27
## 12   Katti         +        B    78      95   99          C  B  49
## 13   Katti         -        B    90      95   99          C  B  49
## 14  Mugger         -        B    95      71   94          A  C  26
## 15   Rohit         +        A    94      92   71          D  B  37
## 16   Rohit         +        B    79      96   71          C  C  39
## 17   Rohit         -        A    95      92   71          C  B  37
## 18    Venu         +        A   100      92   82          A  E  78
## 19    Venu         -        A    99      92   82          A  E  78
## 20 Vishwas         +        A    82      93   92          B  B  21
## 21 Vishwas         -        A    93      93   92          A  B  21
## 22 DIkChik         +        B    91      71   84          E  C  99
## 23  Vikram         +        B    99      79   98          A  B  99
```

By default, no columns are excluded from the comparison, so any of the tuple of grouping 
variables which are different across the two data frames are shown in the comparison table.

For example, Akshay, Division A has the exact same scores but has two different grades for Discipline across 
the two years so that row is included.

However, Macho, Division B has had the exact same scores in both the years, so his data is not
shown in the comparison table.

## HTML Output
While the comparison, table can be quickly summarized in various forms futher, it is 
very difficult to  process visually, so let's find a way to represent this is a way that is easier 
for the numan eye to read. NOTE: You need to install the `htmlTable` package for the HTML comparison to work.


```r
print(ctable_student$html_output)
```

<table class='gmisc_table' style='border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;' >
<thead>
<tr>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Student</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>chng_type</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Division</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Maths</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Physics</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Chem</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Discipline</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>PE</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Art</th>
</tr>
</thead>
<tbody>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Akshay</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>85</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>36</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Akshay</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>85</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>36</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Ananth</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>78</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>24</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Ananth</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>24</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Bulla</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>97</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>73</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>68</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Bulla</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>73</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>68</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>Dhakkan</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>78</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>96</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>39</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Isaac</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>34</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Isaac</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>34</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Jojy</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>27</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Jojy</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>67</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>27</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Katti</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>78</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>95</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>49</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Katti</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>95</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>49</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>Mugger</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>95</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>94</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>26</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>94</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>D</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>37</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>79</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>96</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>39</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>95</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>37</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Venu</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>100</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>E</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>78</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Venu</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>E</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>78</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Vishwas</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>21</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Vishwas</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>21</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>DIkChik</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>84</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>E</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>99</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>Vikram</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>99</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>79</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>98</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; border-bottom: 2px solid grey; text-align: center;'>99</td>
</tr>
</tbody>
</table>

The same data is represented in tabular form (for further analysis, if necessary) in the
`comparison_table_diff` object


```r
ctable_student$comparison_table_diff
```

```
##    Student chng_type Division Maths Physics Chem Discipline PE Art
## 1        0         2        0     0       0    0          2  0   0
## 2        0         1        0     0       0    0          1  0   0
## 3        0         2        0     2       0    0          0  0   0
## 4        0         1        0     1       0    0          0  0   0
## 5        0         2        0     2       0    0          0  0   0
## 6        0         1        0     1       0    0          0  0   0
## 7        1         1        1     1       1    1          1  1   1
## 8        0         2        0     0       0    0          2  0   0
## 9        0         1        0     0       0    0          1  0   0
## 10       0         2        0     2       0    0          0  0   0
## 11       0         1        0     1       0    0          0  0   0
## 12       0         2        0     2       0    0          0  0   0
## 13       0         1        0     1       0    0          0  0   0
## 14       1         1        1     1       1    1          1  1   1
## 15       0         2        2     2       2    0          2  2   2
## 16       0         2        2     2       2    0          2  2   2
## 17       0         1        1     1       1    0          1  1   1
## 18       0         2        0     2       0    0          0  0   0
## 19       0         1        0     1       0    0          0  0   0
## 20       0         2        0     2       0    0          2  0   0
## 21       0         1        0     1       0    0          1  0   0
## 22       2         2        2     2       2    2          2  2   2
## 23       2         2        2     2       2    2          2  2   2
```

## Change Count and Summary
You can get an idea of what has changed using the `change_count` object in the output. A summary 
of the same is provided in the `change_summary` object.


```r
ctable_student$change_count
```

```
## Source: local data frame [2 x 4]
## 
##   variable changes additions removals
##      (chr)   (dbl)     (dbl)    (dbl)
## 1        0       0         0        0
## 2        0       0         0        0
```


```r
ctable_student$change_summary
```

```
##   old_obs   new_obs   changes additions  removals 
##        12        13         0         0         0
```

## Grouping Multiple Columns


```r
ctable_student_div = compare_df(results_2011, results_2010, c("Division", "Student"))
```

```
## Grouping grouping columns
```

```
## Creating comparison table...
```

```
## Creating HTML table for first 100 rows
```

```r
print(ctable_student_div$html_output)
```

<table class='gmisc_table' style='border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;' >
<thead>
<tr>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>grp</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>chng_type</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Division</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Student</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Maths</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Physics</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Chem</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Discipline</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>PE</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Art</th>
</tr>
</thead>
<tbody>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>1</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Akshay</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>85</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>36</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>1</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Akshay</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>85</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>36</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>2</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Ananth</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>78</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>24</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>2</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Ananth</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>24</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>3</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Isaac</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>34</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>3</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Isaac</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>91</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>34</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>4</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>94</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>D</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>37</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>4</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>95</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>37</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>5</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Venu</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>100</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>E</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>78</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>5</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Venu</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>E</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>78</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>6</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Vishwas</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>82</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>21</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>6</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Vishwas</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>93</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>92</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>21</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>7</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Bulla</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>97</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>73</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>68</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>7</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Bulla</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>84</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>73</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>68</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>8</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>DIkChik</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>91</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>84</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>E</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>99</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>9</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Jojy</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>27</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>9</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>Jojy</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>67</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>92</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>81</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>A</td>
<td style='padding: .2em; color: grey; background-color: #ffffff; text-align: center;'>27</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>10</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Katti</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>78</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>95</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>49</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>10</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>-</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>Katti</td>
<td style='padding: .2em; color: red; background-color: #dedede; text-align: center;'>90</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>95</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>C</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: grey; background-color: #dedede; text-align: center;'>49</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>12</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>Rohit</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>79</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>96</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>71</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: green; background-color: #ffffff; text-align: center;'>39</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>13</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>+</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>Vikram</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>99</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>79</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>98</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>A</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>B</td>
<td style='padding: .2em; color: green; background-color: #dedede; text-align: center;'>99</td>
</tr>
<tr style='background-color: #ffffff;'>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>14</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>-</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>Dhakkan</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>78</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>96</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #ffffff; text-align: center;'>39</td>
</tr>
<tr style='background-color: #dedede;'>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>15</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>-</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>B</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>Mugger</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>95</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>71</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>94</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>A</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>C</td>
<td style='padding: .2em; color: red; background-color: #dedede; border-bottom: 2px solid grey; text-align: center;'>26</td>
</tr>
</tbody>
</table>
## Excluding certain Colums

## Limiting

## Tolerance


#===============================================================================
message("Exclude")

#===============================================================================
message("limit")

#limit warning



```
