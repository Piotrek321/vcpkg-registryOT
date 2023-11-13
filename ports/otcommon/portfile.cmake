set(OTCOMMON_REPO "https://github.com/Open-Transactions/otcommon")
set(OTCOMMON_COMMIT "0e4744449d6e4d1c8f1020e0435f2c5cb835a4bd")
set(SOURCE_PATH "${DOWNLOADS}/otcommon.git")
set(OTCOMMON_VERSION_STRING "1.0.2")
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

find_program(GIT git git.cmd NO_CMAKE_FIND_ROOT_PATH)

if(GIT-NOTFOUND)
  message(FATAL_ERROR "git not found.")
endif()

if(EXISTS "${SOURCE_PATH}")
  vcpkg_execute_in_download_mode(
    COMMAND
    "${GIT}"
    -C
    "${SOURCE_PATH}"
    remote
    set-url
    origin
    "${OTCOMMON_REPO}"
  )
  vcpkg_execute_in_download_mode(
    COMMAND
    "${GIT}"
    -C
    "${SOURCE_PATH}"
    remote
    update
    -p
  )
else()
  vcpkg_execute_in_download_mode(
    COMMAND
    "${GIT}"
    clone
    --recurse-submodules
    "${OTCOMMON_REPO}"
    "${SOURCE_PATH}"
  )
endif()

vcpkg_execute_in_download_mode(
  COMMAND
  "${GIT}"
  -C
  "${SOURCE_PATH}"
  reset
  --hard
  "${OTCOMMON_COMMIT}"
)
vcpkg_execute_in_download_mode(
  COMMAND
  "${GIT}"
  -C
  "${SOURCE_PATH}"
  submodule
  update
  --init
  --recursive
)

vcpkg_cmake_configure(
  SOURCE_PATH
  "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
  -Dotcommon_GIT_VERSION=${OTCOMMON_VERSION_STRING}
  OPTIONS_RELEASE
  -DOTCOMMON_INSTALL_LICENSE=ON
  -DOTCOMMON_LICENSE_FILE_NAME=copyright
  OPTIONS_DEBUG
  -DOTCOMMON_INSTALL_LICENSE=OFF
  -DOTCOMMON_INSTALL_FORMAT=OFF
  -DOTCOMMON_CMAKE_INSTALL_PATH=${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake
)

vcpkg_cmake_install()
