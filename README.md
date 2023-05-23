# makemkv-batch
PowerShell script to automate batch DVD remuxing of VIDEO_TS folders and .ISO image files to MKV files.

![image](https://github.com/gravelfreeman/makemkv-batch/assets/44218371/548e30ad-893e-49aa-bd33-2ea1fb7fa5fe)

## How to use the script
1. Download the script from this GitHub repo
2. Open Windows PowerShell with Run as Administrator to make sure you have the highest permission to make the policy changes
3. Set the execution policy to RemoteSigned
```
PS> Set-ExecutionPolicy RemoteSigned
```
4. Open the script and press the green Play button to run the script
5. You'll be prompted to enter the path of your media root folder
6. Wait until the processing is completed

## Features
- VIDEO_TS folders supported
- ISO files supported
- Simultaneously remux VIDEO_TS and ISOs
- Comprehensive logging under ./Logs
- Progress bar and results
- Work on SMB share

## Additional informations

Since this script can't customized which audio and subtitle tracks to remux in the output file you can use MKVcleaver to remove all unwanted tracks

https://www.videohelp.com/software/MKVcleaver

If you've used a custom installation directory; specify the location of the makeMkvCon64.exe executable on line 2 of the script
```
$exeLoc = "C:\Program Files (x86)\MakeMKV\makeMkvCon64.exe"
```
Recommended directory structure
```
|- root
|--- dvd1
|------ video_ts
|--- dvd2
|------ video_ts
|--- dvd3
|------ dvd3.iso
```
While it supports ISO files in the root, it's not advised to do so since the filenames are all the same and will overwrite the previous files. It's recommended to put individual ISOs in a subfolder like explained above in the recommended directory structure. If you have thousands of ISOs in the same folder use a script to move them in a subfolder.
```
|- root           (not recommended)
|--- dvd4.iso     (not recommended)
|--- dvd5.iso     (not recommended)
```
The script might or might not work with custom DVDs. If you find an incompatible DVD you might want to try it in MakeMKV CLI but chances are that it wont work either.

## Please read this
I need help to enhance this script. I would like this script to be able to, append the folder name where the VIDEO_TS folder is in, to the output filename. I would also like to add language support where the user would be prompted to choose from a list of language and separate them by comma (ex. all,eng,fre,rus...), both for the audio track and the subtitle track. Reading throught the makemkvcon documentation, I feel like it's not possible yet. I wonder if I could do this with mkvtoolnix as a second pass after the remux. Contact me if you would like to help!

## Credits
- Freeman __ *$Programmer*
