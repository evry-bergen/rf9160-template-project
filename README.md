NRF9160 Zephyr-project template
===============================


# Clone repo

```sh
$ export PROJECT_DIR=$(pwd)/myproj 	# Change this to suit your needs
$ git clone $REPO_URL $PROJECT_DIR
$ cd $PROJECT_DIR
$ git submodule update --init --recursive
```


# Install requirements

## Install Python-packages

```sh
$ python -mensurepip
$ pip install -r ncs/zephyr/scripts/requirements.txt
$ pip install -r ncs/nrf/scripts/requirements.txt
```


### Install toolchain

Zephyr SDK currently does not support Cortex-m33, so we need to install GCCv8 instead.

Go to [this link](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads) and download version 8. After download is complete:

```sh
$ cd ~/Downloads  ## Assuming toolchain downloaded to this directory
$ mkdir -p /opt/gcc-arm-none-eabi
$ mv gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2 /opt/gcc-arm-none-eabi
$ cd /opt/gcc-arm-none-eabi
$ tar xfv gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
$ mv gcc-arm-none-eabi-8-2018-q4-major 8.2018.q4-major
$ ln -s 8.2018.q4-major latest
```

Ensure the toolchain is specified in the PATH-variable.

### Install JLink-tools

Go to the [Segger website](https://www.segger.com/downloads/jlink/) and download the _Software and Documentation Pack_ for your platform.

Ensure the JLink-tools are specified in the PATH-variable.


## Building

```sh
$ cd $PROJECT_DIR
$ mkdir -p build && cd $_
$ export ZEPHYR_TOOLCHAIN_VARIANT="gnuarmemb"
$ export GNUARMEMB_TOOLCHAIN_PATH="/opt/gcc-arm-none-eabi/latest"
$ source ../ncs/zephyr/zephyr_env.sh
$ cmake -GNinja -DBOARD=nrf9160_pca10090 -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCONF_FILE=prj.conf ../app
$ ninja
```


## Debugging

Open two terminals. In the first terminal, run the following (try running as root if it does not work):

```sh
$ JLinkGDBServer -device nrf9160 -if SWD
```

In the second terminal:

```sh
$ cd $PROJECT_DIR/build
$ /opt/gcc-arm-none-eabi/latest/bin/arm-none-eabi-gdb
```

This will load a GDB-shell:

```gdb
(gdb) target remote :2331
(gdb) load zephyr/zephyr.elf
(gdb) b main
(gdb) mon reset
(gdb) c
```

This should hopefully trigger a breakpoint in `main()`, indicating everyting is working fine. After the breakpoint is triggered, issue the following command:

```gdb
(gdb) c
```


## Building Secure-Boot

Some of the examples provided by Nordic-Semi require secure-boot to function properly. To help anyone confused by this, we have provided a helper-script which compiles and
flashes the target in a single command:

```sh
$ scripts/build-and-program.sh -b
```

This helper-script also provides a target for the AT-Client example provided by Nordic-Semi. See `scripts/build-and-program.sh --help` for more details.


## Using VsCode

Install [VsCode](https://code.visualstudio.com) and opend the project directory. This should load a complete development environment complete with build-tasks and debug-configurations

Install the following plugins:

* [C/C++ for Visual Studio Code](https://code.visualstudio.com/docs/languages/cpp)
* [Cortex-Debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug)
* [CMake](https://marketplace.visualstudio.com/items?itemName=twxs.cmake)

After all plugins have been installed open the `$PROJECT_DIR`-directory. The project should be ready to use as-is without any additional configurations.

The following tasks have been configured:

* __Configure__ - Configure project by generating makefiles and running some housekeeping-scripts. Run this task once after opening this project.
* __BUILD__ - Build project.
* __Clean__ - Clean build-files. Project is still configured. No need to run the __Configure__-task after running this task.
* __Pristine__ - Delete contents of build-directory. Project is no longer configured. Run __Configure__ before building project after running this task.

In addition to the tasks above, the following Launch/Debug-configurations have been supplied:

* __Cortex Debug__ - Start JLink GDB-server and connect debugger. Most applications will use this configuration.
* __Cortex Attach__ - Attach debugger to running GDB-server.

After starting the Debug-session, the debugger should break at `main()`.

In some cases, the debug-session may be unresponsive. In this case, try clicking "restart" then "continue".


# Where to go next

The NRF9160 Provides of features not explored in this tutorial. To help you get started, here are some resources:

* [NRF9160 Examples](https://github.com/Rallare/fw-nrfconnect-nrf/tree/nrf9160_samples/samples/nrf9160) - NRF9160 Examples provided by GitHub-user [Rallare](https://github.com/Rallare)
* [NRF9160 Documentation](https://www.nordicsemi.com/DocLib?Product=nRF9160%20Core%20Documentation) - NRF9160 Reference Manual, User guides, etc.
* [Zephyr Docs](https://docs.zephyrproject.org/latest/introduction/index.html) - Zephyr Documentation
* [Nordic DecZone](https://devzone.nordicsemi.com/) - Developer Forum for Nordic-Semi platforms such as NRF9160, NRF52, etc.

