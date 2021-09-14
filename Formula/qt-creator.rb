class QtCreator < Formula
  desc "IDE for application development"
  homepage "https://www.qt.io/developers/"

  version "5.0.0"
  url "https://github.com/francoisferrand/qt-creator.git", using: :git, branch: '5.0', revision: "85ce8df1c0e036936f199dacedbfd85c63a5f5a2"

  # TODO: bottles? ttps://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Bottles.md

  head "https://github.com/francoisferrand/qt-creator.git"

  # TODO: option "with-qt=", "Specify alternative Qt installation"
  #    and get args via ARGV.value("with-qt")
  # Alternatively, may just create a "fake" formula, named qt or qt@5 as well, which uses the version from SDK...
  depends_on 'qt@5'
  depends_on 'cmake' => :build
  #depends_on 'ninja' => :build # Make this optional: fallback to make...
  depends_on 'python3'

  resource "libclang" do
    url "https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_120-based-mac.7z"
    sha256 "1b17e3d5622865b14d567cf693bf887886a6e02e5352239d23fcb867038a230a"
  end

  # -DWITH_DOCS : Build documentation
  # -DWITH_TESTS : Build tests
  # Plugin ClangFormat, with CONDITION TARGET libclang AND LLVM_PACKAGE_VERSION VERSION_GREATER_EQUAL 10.0.0 AND QTC_CLANG_BUILDMODE_MATCH
  # Plugin ClangCodeModel, with CONDITION TARGET libclang
  #     Clang build mode mismatch (debug vs release): limiting clangTooling
  #     CMake Warning at src/tools/CMakeLists.txt:4 (message):
  #     Could not find Clang installation - disabling clangbackend.
  # multilanguage-support in qml2puppet, with CONDITION TARGET QtCreator::multilanguage-support
  # not found:  Qt5SvgWidgets

  def install
    # TODO: source path (..)
    resource("libclang").stage "src/libs/libclang"
    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_PREFIX_PATH=#{Formula["qt@5"].prefix};#{buildpath}/src/libs/libclang",
                    "-DPYTHON_EXECUTABLE=#{Formula["python3"].bin}/python3",
                    "-DBUILD_QBS=ON", "-DBUILD_SERIAL_TERMINAL=ON",
                    *std_cmake_args
    system "cmake --build ."
    prefix.install "Qt Creator.app"
  end
end
