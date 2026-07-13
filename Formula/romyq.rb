class Romyq < Formula
  include Language::Python::Virtualenv

  desc "AI project governance and management CLI"
  homepage "https://github.com/Webrowse/romyq"
  url "https://files.pythonhosted.org/packages/f3/9b/0af0e574f4a7f5b3252ae07ffcaed12737e1515ae4f38b971df37eda10d5/romyq-0.11.0.tar.gz"
  sha256 "4d0ecea00be1e9aad87776be479efaae53a2f98899fc4c4df62de7392de7bf45"
  license "MIT"

  depends_on "python@3.13"
  depends_on "expat"

  def install
    stage_pyexpat_fix if OS.mac?
    venv = virtualenv_create(libexec, "python3.13")
    # Install from PyPI wheels instead of resource sdists: the dependency
    # tree (openai -> pydantic-core, jiter) contains Rust extensions that
    # would otherwise be compiled on every user's machine.
    system libexec/"bin/python", "-m", "pip", "install",
           "--quiet", "--no-compile", "romyq==#{version}"
    bin.install_symlink libexec/"bin/romyq"
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
    # Exercise the import chain that needs third-party deps (openai, dotenv):
    # a bare `--help` passes even when the virtualenv is missing them.
    system libexec/"bin/python", "-c", "import romyq.loop"
  end
end
