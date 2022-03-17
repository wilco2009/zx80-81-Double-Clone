# PROJECT DOUBLE CLON ZX80/ZX81

Reading the works of [Grant Searle](http://searle.x10host.com/#ZX80), I have decided to start with the project to build a full computer to understand in depth his functionality. What can be more proper that a ZX80 totally based in discrete chips? 

In my spare time, I have started to work on it and you can find the results in the following lines.

I have copyied the schematics from the original zx80, and have made some modifications on it.

- I have added the extra circuitery to generate /NMI signal (Grant Searle Schematics), making possible to have two machines in one, by selecting it through a switch.
- Original 1K RAM in two chips have been replaced by one SRAM chip of  32KB.
- Original 4K ROM have been replaced by a EEPROM of 32KB. It necesary to store both ROMs (ZX80/ZX81) and it is cheaper than other smaller EPROMs.
-  RF modulator have been removed and replaced by a circuit to generate the standard back porch, missing in the original ZX80 PAL signal.

!ZX80/81 Clone (https://lh3.googleusercontent.com/a3tTZjGUSokoMyUphqR5SHZJ3wfOpXbvwoN9k-QTiYge5uHZ-XYteMHs6ovo985GKbJCe_nP10vpZdp8bHYN9AlXPDZbchsSQltBprkMjSns3KtHl2wMzvuFCLnhYVjMVK5JiA=w996-h1247-no)