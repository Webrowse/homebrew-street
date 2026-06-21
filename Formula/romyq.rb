class Romyq < Formula
  include Language::Python::Virtualenv

  desc "AI project governance and management CLI"
  homepage "https://github.com/Webrowse/romyq"
  url "https://files.pythonhosted.org/packages/source/r/romyq/romyq-0.10.3.tar.gz"
  sha256 "24118f0bb6e0992410af1bd6f86bb406e73fceaf19fa982dff6cd5757346b50a"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    system "#{bin}/romyq", "--help"
  end
end
