So, first you want to run 
* `python docgen.py ..\` 

which will generate numerous RST files, one for each file in SRL

The next step is simply need to run 
* `make html`

That's it, the docs have now been generated.


If you don't have sphinx then get it with pip
* `pip install sphinx`
* `pip install sphinx_rtd_theme`
