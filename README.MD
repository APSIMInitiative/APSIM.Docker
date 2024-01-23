# How to setup the docker container

1. The docker container can be pulled down using this command: ```docker pull apsiminitiative/apsimng```

# How to run an apsimx file
- example run command: ```docker run -i --rm -v "$PWD:/apsim" apsiminitiative/apsimng /apsim/<example-file-name>.apsimx```

1. Make sure you have added the required met file and apsimx file to the directory you'll run the ```docker run``` command within.
2. Change the Weather ```FileName``` property to the file name of the met file.

# Extra notes
- Extra switches can be appended to the docker run command to utilise extra functionality. Some examples are the ```--verbose``` ```--apply``` and any others you can use with Models.exe.
