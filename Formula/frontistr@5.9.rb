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
    ENV["OMPI_CC"] = formula_opt_bin("gcc")/"gcc-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_CXX"] = formula_opt_bin("gcc")/"g++-#{Formula["gcc"].version.major.to_s}"
    ENV["OMPI_FC"] = formula_opt_bin("gcc")/"gfortran-#{Formula["gcc"].version.major.to_s}"
    ENV["CC"] = formula_opt_bin("open-mpi")/"mpicc"
    ENV["CXX"] = formula_opt_bin("open-mpi")/"mpicxx"
    ENV["FC"] = formula_opt_bin("open-mpi")/"mpifort"
    ENV.prepend_path "CMAKE_PREFIX_PATH", formula_opt_prefix("openblas")
    ENV.append "CFLAGS", "-Wno-error=incompatible-pointer-types"

    args = [
      "-DCMAKE_INSTALL_PREFIX=#{prefix}",
      "-DCMAKE_INCLUDE_PATH=#{formula_opt_include("librcaprefiner")}",
      "-DCMAKE_LIBRARY_PATH=#{formula_opt_lib("librcaprefiner")}",
    ]

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
