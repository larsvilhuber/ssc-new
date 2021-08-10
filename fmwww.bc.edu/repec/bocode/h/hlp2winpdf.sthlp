{smcl}
{* December 2009}{...}
{hline}
{cmd:help for hlp2winpdf} 
{hline}

{title:Title}

{p 4 8 2}
{bf:hlp2winpdf --- Prints a list of Stata help files to pdf in Windows Environment}


{title:Syntax}

{phang}
{cmd: hlp2winpdf}{cmd:,}  {opt cdn:ame(command_names)} [{opt replace}]

{synoptline}

{marker description}{dlgtab:Description}

{phang}
{cmd:hlp2winpdf} prints help files for any Stata commands to portable document format (pdf) in Windows Environment.  
The conversion is done via Ghostscript which must be installed for {cmd:hlp2winpdf} to work. A copy of Ghostscript can 
be found at http://pages.cs.wisc.edu/~ghost/. The DOS window will open and close during the conversion process. 
All generated .pdf files are placed in the working directory.

{phang}
{bf:N.B.:} Make sure the help files to be converted are not open in the Viewer.


{title:Options}

{dlgtab:Options}

{pstd}
{opt cdn:ame(command_names)} specifies a list of command names whose help files need to be converted. 

{phang}
{opt replace} overwrites existing .pdf files.


{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, Dept. of Agricultural, Environmental, and Development Economics,{break} 
           The Ohio State University{break}
           
{p 4 4 2}Email to {browse "mailto:jeanty.1@osu.edu":jeanty.1@osu.edu}.


{title:Also see}

{p 4 13 2}Online: {helpb hlp2pdf} if installed

