# PROJECT DOUBLE CLON ZX80/ZX81

Reading the works of [Grant Searle](http://searle.x10host.com/#ZX80), I have decided to start with the project to build a full computer to understand in depth his functionality. What can be more proper that a ZX80 totally based in discrete chips? 

In my spare time, I have started to work on it and you can find the results in the following lines.

I have copyied the schematics from the original zx80, and have made some modifications on it.

- I have added the extra circuitery to generate /NMI signal (Grant Searle Schematics), making possible to have two machines in one, by selecting it through a switch.
- Original 1K RAM in two chips have been replaced by one SRAM chip of  32KB.
- Original 4K ROM have been replaced by a EEPROM of 32KB. It necesary to store both ROMs (ZX80/ZX81) and it is cheaper than other smaller EPROMs.
-  RF modulator have been removed and replaced by a circuit to generate the standard back porch, missing in the original ZX80 PAL signal.

![ZX80/81 Clone](https://lh3.googleusercontent.com/a3tTZjGUSokoMyUphqR5SHZJ3wfOpXbvwoN9k-QTiYge5uHZ-XYteMHs6ovo985GKbJCe_nP10vpZdp8bHYN9AlXPDZbchsSQltBprkMjSns3KtHl2wMzvuFCLnhYVjMVK5JiA=w996-h1247-no)

The final result is nor a exact copy of the original as the case of Grant, but the board match accurately in the original case, and I very happy with the result.

## TECHNICAL & ASSEMBLY INFORMATION

In this project you can find the necesary information to build your own zx80. I think the most funny way to obtain your clon is to do it from zero, but if you wanna a clon and need the PCB or you have not enough knowledge or experience to assembly it, I have some spare PCBs and componentes, and I can sell them or assembly the clon for you. Please feel free to contact me and I'm sure we can reach an agreenment. ;)

Current version: 1.1

![](https://lh3.googleusercontent.com/rCJV6tn4bRtD5xP2J01XtbQhOAFcQkIHwjG2PTs5kUFLTJYEPpwRD9dPU9Wus_7P2roRMrFiV_r6bx4AB1eH3hhHG4VBcHm-jtsIfwT51LC9u5qDKVhMcgAC-uYpSRKtiEv6ICVfqDUmrft0VXdILqsLhS6f-ci5W7Umk74fWQYKdmCltZMjROodQSZJIWuj3sWZtwkx2SUn3Zm80keVlYFTvZAvUO4RSQdXKRYVVGPSJaJdWytPF-uEiMIzvv5qfT4mYDBnC-GfqofApX20-UyLoEvZvTxQKA6cM-wEbGhz7QX-2P5Ngz30T_aOOOsLFDybzaFVSkEu0-Aztuu-lsrUIOo-5BsEfMnfYWue9epBj3OxYwocKKNFXdKxPxSTB5UOF6xXgVXRRxUQgXtDaMdEkAA_8DmF7i70zOS1lgH9-kZtPJs_eu8M_NfuGdDXssUw_kXJS4aPKvZ8_ZMPcppX3AiGHYtJN76VHx3QsB8ZefL5xlYTNOjEyXqZktvqzpaWWwEC28iiI7Rkx7_iQb64YHFRn1RQnPd6H6iP8zeCWNG2FOciLwMQ_T2f79s7PXthGdRW-6iFVxDD1xcBhBEmMfMiO6Gdjo2rIUpM3x4K8OVurMoqewDZ2G1iEkNCWaOpOh4981G3RFsP8XLy4C4ls8FTX44saukjyuqq=w845-h981-no)

## JUMPER POSITION
JP1: RAMOE, Not relevant but must be present in one position
JP2:
              1-2 - Inverse Video
              2-3 - Standard Video
S2: ZX80/81 Mode selection (If you use external selection from the expansion board this jumper have to be removed)
              1-2 - ZX81 mode
              2-3 - ZX80 mode.

S4: Function of the Pin23B in the expansion bus. 
In original ZX80 pin 23B of the expansion bus is spare, but in a ZX81 PIN23B is use as /ROMCS signal.
If you want to use external zx81 mode selection form the expansion board you have to use position 1-2. In this case (in zx81 mode) cards replacing the internal ROM will not works.
If you prefer to use this kind of cards, you have to wire the zx81 selector (S2) directly to an accesible switch and set S4 in 2-3 position (remember to remove JP1 in the expansion board)
              1-2 - ZX81/ZX80 mode selection in PIN 23B
              2-3 - /ROMOE in PIN 23B

### Back porch Grant Searle solution:

              JP3 = 2-3
              JP5 = OFF
              JP6 = 1-2

### Back porch generation José Leandro solution:
              Adjust image with R37 & R33
              JP3 = 1-2
              JP5 = ON
              JP6 = 2-3

### Without Backporch generation (original ZX80 video)
              JP3 = 1-2
              JP5 = OFF
              JP6 = 1-2
              
## EXPANSION BOARD
![](https://lh3.googleusercontent.com/FehGQYNSnNnPpCah7wHeFg3WgHUlYfkYtZd_ZTnBtV3qB9Kp1vZPapiCp3HhxNcqrc4W907gn2rPwl_WTRAhkWCJIaoYuTDla1NeWNFWmHeGPT0kxNU7hTfsO6rRErti0l2Dww=w640-h480-no)
This board has double functionality, first leaves enough room to connect zx81 cards  without trip with the video connector, and by other hand adds some extra functionality to the main board.
![](https://4.bp.blogspot.com/-SfDro-BBRE8/WV-5-jXwvSI/AAAAAAABq60/8qCJKzkmQEkw76GXQsi_B6LsdW6DJfg1wCK4BGAYYCw/s320/ADDON_ZX80_esquema.png)

Expansion board let you to supply power to the computer with a miniUSB charger. If you plan to use external cards using 9V you will must to connect the computer to a 9V PS through the standard conector.
If you use the miniUSB supply, you could use the ON/OFF switch present in the board (S1) to turn on the computer.
S2 is a reset button, and it will works in any case.
JP7 Lets you to select ZX80/81 mode from the board if the position of the main jumper S4 is 1-2 and JP1 in the expansion board is ON.

JP1 Lets you aisle pin23B in the computer from the JP7 selector. It must be OFF if computer jumper S4 is 2-3.

![Clon working together with the ZXBlast](https://lh3.googleusercontent.com/j9ALMYmShmvCE-jy-AzifAf2zu_0noKhuHjYqihIMtmODiZwof2czWIUYXH-UqWGO6TdXiLnMDjAKpj7Po1c5WaS6kIWaJdyXEqjynNArSz48OjEJksTGsXhDxQqEvnr6YDXmGl5VvESaMWlwIdJ6xjhwu2kQWZDYximzGeFjO39mOyrUMT1J-gvP3T8bGvWy7lPkWDsSiR0pI6hCDJZr2bOI1wuq31htQXp7wsT5vWe7ypyu1pTyPivk21z11Azjm-WXjnvVRQzJSwvq5q3OPzuYVv2PyCXvG03Tv6p_5taKzRV-rwySb_m_U9nDuxuRpI7Uc-8QEj6cFWM4ZI8NtL62JtfRc3yyowyizVgGyirSfv9Bk2rxOZqB-cOk6DNdtdGGdJT4QNYqnln8sdsbW3eD9JWjGkwFdYOPOAoj-ihRwhNHcHDzzXuyWnVDI54tBXznl0jK5OOICXLZPlEjcX42goKXJJ15L38fqvd_e-W1liQFMYBwjwnZQ0DPTSEEiSlLOfVQjilyQhW0fKNTQ-jeCu2VwTQkMloKwc0vevMCimGE85adegjdQxXJi_FQP6vlO9OII5GSUV8qNXudLEAzHOdmtRVcGPY-64G44qyDU0Gr9a-xIT18pK3NaAvpgWDecYkdOFkBCX6qmApyG_PxvDnz6c9Qs07RMNK=w1156-h981-no)

CONTACT: wilcoavs at gmail dot com

![](https://2.bp.blogspot.com/-tJBpHi4lipA/WdqxxrlYZ6I/AAAAAAABs5c/YHKejNn-AMgrKOYefYAowYfHLzalZ9-9wCLcBGAs/s320/email.png)

Update 01/02/2020.
Fix to resolve an incompatibility with some 74LS00s who inverts the screen. It is necessary to insert a 47K resistor between pin 1 and pin 14 of IC 11.

Update 17/02/2021 (many thanks to Augusto Baffa)
Quoted Augusto Baffa:
"My signal clock from IC18 PIN 9 was about (0-3v) and the High Pass Filter created by R25 and C11 was about (0-1v). It works on IC16 PIN 9 to generate the pulse that loads S/L on IC9 PIN 1 but was not working to load the latch'd on normal/inverse circuit 'cos IC11 pin 3 was always high.

So, after some testing I found that it's necessary to use another high pass filter to feed IC11 PIN2. I'm using a 100pF capacitor and a 3k6 resistor. After that it works fine. 

![](https://1.bp.blogspot.com/-3URLNU0KFKU/YC08P728yUI/AAAAAAACKHQ/lhgB2oVaM2ASNiKkZz7T3TT9pud1MCJxgCLcBGAsYHQ/s320/unnamed.png)

there is another item that could be improved. I've tested the Ear/cassete interface and it's producing a very low signal to IC10 PIN2.
 I analyzed the circuit on proteus and compared with original zx81 schematics and get the following:

Blue signal (it's dark... sorry)  is the signal produced by the original Searle's version. The red one is my propose in order to use the same PCB holes. and the green is the signal produced by the original zx81 circuit."

![](https://1.bp.blogspot.com/-fwFtGPbVKYY/YC08uQwjyWI/AAAAAAACKHc/FCEmRSYtLG0cXIXtxGl_CXDEQHExYZ5RACLcBGAsYHQ/s320/unnamed%2B%25281%2529.png)

https://wilco2009.blogspot.com/2017/07/project-double-clon-zx80zx81-reading.html

## ACKNOLEDGEMENTS
- Jim Westwood - To Design the original machine
- Clive Sinclair - To introduce me in the computers world.
- Grant Searle - To Grant Searle for his excellent work, he was the origin of mine. 
- Jose_Leandro, habbisoft - (in special way to jose_leandro) To help me in de debugging phase
- alvaroalea - to create a amaizing 3d printed case.
- carmeloco,flopping,sinclair200 - for supporting me in the initial phase
