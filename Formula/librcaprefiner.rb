class Librcaprefiner < Formula
  desc ""
  homepage "https://github.com/chikasuiro/REVOCAP_Refiner"
  url "https://github.com/chikasuiro/REVOCAP_Refiner/archive/refs/tags/v1.1.04.tar.gz"
  sha256 "f0eca0631c0c3de48b0bf63406216303586cf6091e41cae2ecccc378cf0ab52b"
  license ""

  depends_on "gcc"

  def install
    ENV["HOMEBREW_CC"] = Formula["gcc"].opt_bin/"gcc-#{Formula["gcc"].version.major.to_s}"
    ENV["HOMEBREW_CXX"] = Formula["gcc"].opt_bin/"g++-#{Formula["gcc"].version.major.to_s}"
    system "sed", "-i", "-e", "s/x86_64-linux//", "./MakefileConfig.in"
    system "make"
    mkdir_p("#{lib}")
    cp("./lib/libRcapRefiner.a", "#{lib}")
    mkdir_p("#{include}")
    cp("./Refiner/rcapRefiner.h", "#{include}")
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <rcapRefiner.h>

      int main() {
        int n_elem = 1;
        int etype_rcap = RCAP_HEXAHEDRON;
        int elem_node_item[8] = {0, 1, 2, 3, 4, 5, 6, 7};
        size_t n_elem_ref;

        rcapGetVersion();
        n_elem_ref = rcapRefineElement(n_elem, etype_rcap, elem_node_item, NULL);

        printf("Number of refined elements: %zu\\n", n_elem_ref);
        return 0;
      }
    C
    ENV["CC"] = Formula["gcc"].opt_bin/"gcc-#{Formula["gcc"].version.major.to_s}"
    flags = ["-I#{include}", "-L#{lib}", "-lRcapRefiner", "-lstdc++"]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
