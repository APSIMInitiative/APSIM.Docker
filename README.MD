# APSIM using Docker

Running APSIM through docker can simplify the setup. Docker provides a method to get the dependencies and functionality in a single digital object that runs across multiple operating systems. 

After [setting up docker](https://www.docker.com/get-started/), you need to pull the APSIM image, ensure the target `.apsimx` file is properly configured for you system, and run a docker container using the simulate file as input. If you are beginning with examples from the [ApsimX repo](https://github.com/APSIMInitiative/ApsimX), also make sure you've clone have the code locally so it can be mounted to the docker container.

## 1. Pull the APSIM Docker Image

Ensure docker is running. Then pull the apsimng image. You only need to do this once.

`docker pull apsiminitiative/apsimng`

## 2. Run an Example Simulation

```bash
# Navigate your terminal to you copy of ApsimX (cloned from https://github.com/APSIMInitiative/ApsimX)
cd /your/path/to/APSIMInitiative/ApsimX

#To run APSIM, we launch a container (which essentially intantiates a live process from the static image)
docker run -i --rm -v "$PWD:/ApsimX" apsiminitiative/apsimng /ApsimX/Examples/Wheat.apsimx
```

The above:
* uses the `run` command to launch a container from the `apsiminitiative/apsimng` image
* passes the `-i` flag to run in interactive mode (attached to the terminal)
* passes the `--rm` flag to tell docker to delete the container once the simulation finishes (saving disk space by not accumulating stopped containers)
* passes the `-v` command to mount a volume. This mounts the present working directory on the host machine to `/ApsimX` within the docker container so it has access to the examples at `ApsimX/Examples`. 

## Notes
### Usage on Non-Windows Machines (e.g., Mac or Linux)
The above Wheat example (and others) in `ApsimX/Examples/*.apsimx` specify file locations using a Windows file string convention. You'll need to modify any specified files in the `.apsimx` file to match your OS.

In the above example, Mac/Linux users will likely need to change the filepath specified in the Models.Climate.Weather from `"%root%\\Examples\\WeatherFiles\\Dalby.met"` to `"/ApsimX/Examples/WeatherFiles/Dalby.met"`

### Customizing the Docker Container Call
* When building your own workflow, you will likely want to modify the volume mount and `.apsimx` file locations.
* Extra switches can be appended to the docker run command to utilise extra functionality. Some examples are the `--verbose`, `--apply`, and any others you can use with Models.exe. Additional `docker run` options are listed in the [docker documentation](https://docs.docker.com/reference/cli/docker/container/run/).
