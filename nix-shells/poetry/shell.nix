{ pkgs ? import <nixpkgs> {} }:
let
  customPoetry = pkgs.writeShellScriptBin "poetry" ''
    # Python packages come pre built and sometimes assume there are c libraries available on the system
    # Usually because they are but the nix way is to isolate packages by default so we need to provide
    # the right LD_LIBRARY_PATH to get it to work
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zlib ]}:$LD_LIBRARY_PATH"
    exec ${pkgs.poetry}/bin/poetry $@
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Use custom poetry wrapper instead of the regular one
    customPoetry

    # Basic build tools
    gcc
    glibc
    glibc.dev
    gnumake
    ninja
    pkg-config
    
    # Python 
    python312
    
    # Scientific libraries needed for numpy and other scientific packages
    openblas
    gfortran
    
    # Additional libraries that might be needed
    zlib
    stdenv.cc.cc.lib


    # Basic build tools
    gcc
    gnumake
    ninja
    pkg-config
    
    # Python and dependencies
    python312
    poetry
    
    # Scientific libraries
    gfortran      # Fortran compiler for scientific packages
    openblas      # Optimized BLAS implementation
  ];
 
  shellHook = ''
    # Make sure the C compiler can find the necessary headers
    export NIX_CFLAGS_COMPILE="-isystem ${pkgs.glibc.dev}/include $NIX_CFLAGS_COMPILE"
    export C_INCLUDE_PATH="${pkgs.glibc.dev}/include:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="${pkgs.glibc.dev}/include:${pkgs.gcc.cc}/include/c++/${pkgs.lib.getVersion pkgs.gcc.cc}:$CPLUS_INCLUDE_PATH"
    
    # You might not need these since customPoetry already sets LD_LIBRARY_PATH
    export LIBRARY_PATH="${pkgs.glibc}/lib:$LIBRARY_PATH"
    
    echo "Python development environment activated."
    echo "Use 'poetry install' to install dependencies."
  '';
}
