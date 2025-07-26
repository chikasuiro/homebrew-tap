# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Librcaprefiner < Formula
  desc "REVOCAP_Refiner"
  homepage "https://github.com/FrontISTR/REVOCAP_Refiner"
  url "https://github.com/FrontISTR/REVOCAP_Refiner/archive/refs/tags/v1.1.04.tar.gz"
  sha256 "a22e27f6a9ce5c8e79af28c062e597ae5d7cf6345a84ad3c52342b4c27946c15"
  license ""

  depends_on "gcc@15" => :build

  def install
    system "sed", "-i", "-e", "s/gcc/gcc-15/g", "./MakefileConfig.in"
    system "sed", "-i", "-e", "s/g++/g++-15/g", "./MakefileConfig.in"
    system "sed", "-i", "-e", "s/x86_64-linux//", "./MakefileConfig.in"
    system "make"
    system "cp", "./lib/libRcapRefiner.a", "#{lib}/"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test librcaprefiner`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
