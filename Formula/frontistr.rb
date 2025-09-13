class Frontistr < Formula
  desc "Open-Source Large-Scale Parallel FEM Program for Nonlinear Structural Analysis"
  homepage "https://www.frontistr.com/"
  url "https://gitlab.com/FrontISTR-Commons/FrontISTR/-/archive/v5.7.1/FrontISTR-v5.7.1.tar.gz"
  version "5.7.1"
  sha256 "5c6e5caf8eb79352b63bb8e23635caeb4729e6577edbfa1de32a8ab270261f22"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "gcc"
  depends_on "open-mpi"
  depends_on "metis"
  depends_on "openblas"
  depends_on "scalapack"

  def install
    ENV["OMPI_CC"] = Formula["gcc"].opt_bin/"gcc-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_CXX"] = Formula["gcc"].opt_bin/"g++-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_FC"] = Formula["gcc"].opt_bin/"gfortran-#{Formula["gcc"].version.major.to_s}"
    ENV["CC"] = Formula["open-mpi"].opt_bin/"mpicc"
    ENV["CXX"] = Formula["open-mpi"].opt_bin/"mpicxx"
    ENV["FC"] = Formula["open-mpi"].opt_bin/"mpifort"
    ENV["CMAKE_PREFIX_PATH"] = Formula["openblas"].opt_prefix

    args = ["-DCMAKE_INSTALL_PREFIX=#{prefix}"]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--", "-j"
    system "cmake", "--build", "build", "--target", "install"
  end

  test do
    system "#{bin}/fistr1", "-v"
  end
end
