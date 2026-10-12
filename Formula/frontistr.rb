class Frontistr < Formula
  desc "Open-Source Large-Scale Parallel FEM Program for Nonlinear Structural Analysis"
  homepage "https://www.frontistr.com/"
  url "https://gitlab.com/FrontISTR-Commons/FrontISTR/-/archive/v5.9/FrontISTR-v5.9.tar.gz"
  version "5.9"
  sha256 "737bfd3a376559745826e6db0f9119faa5b70b2b9c14cad027791010a7933be5"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "gcc"
  depends_on "open-mpi"
  depends_on "metis"
  depends_on "openblas"
  depends_on "scalapack"
  depends_on "netcdf"
  depends_on "librcaprefiner"

  def install
    ENV["OMPI_CC"] = Formula["gcc"].opt_bin/"gcc-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_CXX"] = Formula["gcc"].opt_bin/"g++-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_FC"] = Formula["gcc"].opt_bin/"gfortran-#{Formula["gcc"].version.major.to_s}"
    ENV["CC"] = Formula["open-mpi"].opt_bin/"mpicc"
    ENV["CXX"] = Formula["open-mpi"].opt_bin/"mpicxx"
    ENV["FC"] = Formula["open-mpi"].opt_bin/"mpifort"
    ENV.append "CMAKE_PREFIX_PATH", Formula["openblas"].opt_prefix
    ENV.append "CMAKE_INCLUDE_PATH", Formula["librcaprefiner"].opt_include
    ENV.append "CMAKE_LIBRARY_PATH", Formula["librcaprefiner"].opt_lib
    ENV.append "CFLAGS", "-Wno-error=incompatible-pointer-types"

    args = ["-DCMAKE_INSTALL_PREFIX=#{prefix}"]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--", "-j"
    system "cmake", "--build", "build", "--target", "install"
  end

  test do
    (testpath/"test.msh").write <<~EOS
      !NODE
       1, 0.0, 0.0, 0.0
       2, 1.0, 0.0, 0.0
       3, 1.0, 1.0, 0.0
       4, 0.0, 1.0, 0.0
       5, 0.0, 0.0, 1.0
       6, 1.0, 0.0, 1.0
       7, 1.0, 1.0, 1.0
       8, 0.0, 1.0, 1.0
      !ELEMENT, TYPE=361
       1, 1, 2, 3, 4, 5, 6, 7, 8
      !MATERIAL, NAME=M1
      !ITEM=1, SUBITEM=2
       210000.0, 0.3
      !SECTION, TYPE=SOLID, EGRP=ALL, MATERIAL=M1
      !END
    EOS
    (testpath/"test.cnt").write <<~EOS
      !VERSION
       5
      !SOLUTION, TYPE=STATIC
      !SOLVER, METHOD=CG, PRECOND=3
      !BOUNDARY, GRPID=1
       1, 1, 3
       2, 1, 3
       3, 1, 3
      !CLOAD, GRPID=1
       8, 3, 1000.0
      !END
    EOS
    (testpath/"hecmw_ctrl.dat").write <<~EOS
      !MESH, NAME=fstrMSH, TYPE=HECMW-ENTIRE
       test.msh
      !CONTROL, NAME=fstrCNT
       test.cnt
    EOS
    system "#{bin}/fistr1"
  end
end
