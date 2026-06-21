class Romyq < Formula
  include Language::Python::Virtualenv

  desc "AI project governance and management CLI"
  homepage "https://github.com/Webrowse/romyq"
  url "https://files.pythonhosted.org/packages/source/r/romyq/romyq-0.10.3.tar.gz"
  sha256 "24118f0bb6e0992410af1bd6f86bb406e73fceaf19fa982dff6cd5757346b50a"

  depends_on "python@3.13"
  depends_on "expat"

  def install
    stage_pyexpat_fix if OS.mac?
    virtualenv_install_with_resources
  end

  # pip cannot start on macOS 26.2+CLT 26.0: system libexpat lacks AllocTracker symbols that the Python 3.13 bottle's pyexpat expects.
  def stage_pyexpat_fix
    py = Formula["python@3.13"].opt_bin/"python3.13"
    return if quiet_system(py, "-c", "import xml.parsers.expat")

    src = Dir.glob("#{Formula["python@3.13"].opt_prefix}/**/pyexpat.cpython-*-darwin.so").first
    return unless src

    dynload = libexec/"lib/python3.13/lib-dynload"
    dynload.mkpath
    dst = dynload/File.basename(src)
    cp File.realpath(src), dst
    system "install_name_tool", "-change",
      "/usr/lib/libexpat.1.dylib",
      (Formula["expat"].opt_lib/"libexpat.1.dylib").to_s,
      dst.to_s
    system "codesign", "--sign", "-", "--force",
           "--preserve-metadata=entitlements,identifier,flags", dst.to_s
    ENV.prepend_path "PYTHONPATH", dynload.to_s
  end

  test do
    system "#{bin}/romyq", "--help"
  end
end
