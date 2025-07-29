# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Frontistr < Formula
  desc "Open-Source Large-Scale Parallel FEM Program for Nonlinear Structural Analysis"
  homepage "https://www.frontistr.com/"
  url "https://gitlab.com/FrontISTR-Commons/FrontISTR/-/archive/master/FrontISTR-master.tar.gz"
  version "5.7"
  sha256 "01935a7548b6a16bc0f394dd6b3453c4e723f7d46a670455ec787409cd41b356"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "gcc" => :build
  depends_on "open-mpi" => :build
  depends_on "libomp" => :build
  depends_on "metis" => :build
  depends_on "openblas" => :build
  depends_on "scalapack" => :build

  def install
    ENV["CC"] = Formula["open-mpi"].opt_bin/"mpicc"
    ENV["CXX"] = Formula["open-mpi"].opt_bin/"mpicxx"
    ENV["FC"] = Formula["open-mpi"].opt_bin/"mpifort"
    ENV["OpenMP_ROOT"] = Formula["libomp"].opt_prefix if OS.mac?
    ENV["CMAKE_PREFIX_PATH"] = Formula["openblas"].opt_prefix

    args = []
    if OS.mac?
      args << "-DOpenMP_C_FLAGS=-Xpreprocessor -fopenmp -I#{Formula["libomp"].opt_include}"
      args << "-DOpenMP_C_LIB_NAMES=omp"
      args << "-DOpenMP_CXX_FLAGS=-Xpreprocessor -fopenmp -I#{Formula["libomp"].opt_include}"
      args << "-DOpenMP_CXX_LIB_NAMES=omp"
    end
    args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--", "-j"
    system "cmake", "--build", "build", "--target", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test frontistr`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
