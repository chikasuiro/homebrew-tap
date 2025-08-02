class Librcaprefiner < Formula
  desc ""
  homepage "https://github.com/chikasuiro/REVOCAP_Refiner"
  url "https://github.com/chikasuiro/REVOCAP_Refiner/archive/refs/tags/v1.1.04.tar.gz"
  sha256 "f0eca0631c0c3de48b0bf63406216303586cf6091e41cae2ecccc378cf0ab52b"
  license ""

  depends_on "gcc" => :build

  def install
    gcc_bin = Formula["gcc"].opt_bin
    gcc_executables = Dir["#{gcc_bin}/gcc-*"].select do |f|
      File.executable?(f) && f.match(/gcc-(\d+)$/)
    end
    if gcc_executables.any?
      latest_gcc = gcc_executables.max_by { |f| f.match(/gcc-(\d+)$/)[1].to_i }
      gcc_version = latest_gcc.match(/gcc-(\d+)$/)[1]
      ENV["HOMEBREW_CC"] = latest_gcc
      ENV["HOMEBREW_CXX"] = latest_gcc.gsub("gcc-", "g++-")
    else
      odie "No GCC executables found in #{gcc_bin}"
    end

    system "sed", "-i", "-e", "s/x86_64-linux//", "./MakefileConfig.in"
    system "make"
    mkdir_p("#{lib}")
    cp("./lib/libRcapRefiner.a", "#{lib}")
    mkdir_p("#{include}")
    cp("./Refiner/rcapRefiner.h", "#{include}")
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
