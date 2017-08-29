#the path to search - this should be replaced with an argument
$path = "c:\code"

#signatures for common file types - this should be expanded and maybe moved to an external file to read in
$filetypes = @{"pdf" = "25504446";"doc" = "D0CF11E0";"docx" = "504B0304";"xls" = "D0CF11E0";"xls2" = "093C7461";"xlsx" = "504B0304"}

#put together the list of files that we will inspect
$targets = Get-ChildItem -file -Path $path -recurse -include ('*.pdf','*.doc','*.docx','*.xls','*.xlsx')

#iterate through the list of files
foreach ($file in $targets){

#pull out the file extension and trim the dot from the front of it
    #write-host "checking" $file
    $fileextension = [IO.Path]::GetExtension($file)
    $fileextension = $fileextension.trim(".")
    #write-host "this is a" $fileextension "file according to the file extension"

#get the magic number from the file
    $filemagicnumber = $null
    [Byte[]]$fileheader = Get-Content -Path $file -TotalCount 4 -Encoding Byte

    ForEach($_ in $fileheader) {
        if(("{0:X}" -f $_).length -eq 1)
            {
             $filemagicnumber += "0{0:X}" -f $_
            }else{
             $filemagicnumber += "{0:X}" -f $_
            }
    }
    #write-host "magic number from file" $filemagicnumber

#iterate through the hash and compare each key against the file extension to fine what the magic number for that extension should be
#using a loop for this is horrible, figure out how to do this in a more hash-friendly way
    foreach ($key in $filetypes.Keys) {
       #write-host "checking" $fileextension "against" $key
        if ($key -eq $fileextension) {
            $lookupmagicnumber = $filetypes.item($key)
            break
        }
    }

#iterate though the hash and compare each value to find what the extension for the magic number should be
     foreach ($value in $filetypes.values) {
        #write-host "checking" $filemagicnumber "against" $value
        if ($value -eq $filemagicnumber) {
            #write-host "matched the magic number" $value
            #$lookupextension = $filetypes.item($key)
            $lookupextension = $filetypes.keys | ? {$filetypes[$_] -eq $value}
            #write-host "lookupextension is" $lookupextension
            break
        }
    }   

#if the magic number from the file and the magic number that matches the extension aren't the same, say so    
    if ($lookupmagicnumber -ne $filemagicnumber){
        write-host "extension from file -" $fileextension
        write-host "magic number should be -" $lookupmagicnumber

        write-host "magic number from file -" $filemagicnumber
        write-host "extension should be -" $lookupextension  
    }
}