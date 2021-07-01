# Basys3_VGA_Driver
VGA display driver for Basys3 FPGA

## Setting Up Distributed ROM
1. In the left side panel, under `Project Manager`, select `IP Catalog`
![Step_1](/Open_IP-Catalog.PNG)

2. Search `ROM` and double-click on `Block Memory Generator`
![Step_2](/search_and_select.PNG)

3. Change name to `BITMAP_ROM` and set the memory type to `Single Port ROM`
![Step_3](/set_name_and_single_port_ROM.PNG)

4. Select the `Port A Options` tab. Set port A width and depth to `128` and set the enable port type to `Always Enabled`.
![Step_4](/set_width_depth_en.PNG)

5. Select the `Other Options` tab. Check the `Load Init File` and the `Fill Remaining Memory Locations` checkboxes. Select browse and locate the `ascii_pixel.coe` file (It is recomended to save it under sources in your project's directory). Click `Ok`.
![Step_5](/set_init_file_and_default_value.PNG)
