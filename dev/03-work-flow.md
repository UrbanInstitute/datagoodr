# Work flow for 03 steps

Load all 03-\*-\*.R files and completed dgf file. The general workflow of the `RG.qmd` file (and thus the 03 steps) is the following:

Run `` `create_section(dgf) `` and for each variable in the dgf it will...

1.  start a new page with the "div1" title

2.  Call `create_section` to make the rest of the section for that variable. This function find the variable class listed in the DGF for the given variable then finds the appropriate layout. For this layout, it lists all the associated divs inside the layout. For each div number listed in the layout ...

    A. Call `create_div` which for each div number finds the appropriate column in the DGF and pulls in that data. It then sends that data to the associated function for that DIV

    B. Runs the given function for the associated div number and pasts the contents into the RG. Tables are pasted as html code. (div2, div3, and div4 always call `v_to_txt` and just paste the inputted data as text. The other divs are the `paste_[preview/stats/graphics]` functions.

Right now we split up the DGF by variable type then render a `create_section(dgf_[datatype])` in a new section for each type. Each figure type requires a different fig.width and fig.height that can't be manipulated by `par` from a quarto document. This can probably be changed later, but for now it works.
