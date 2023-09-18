set(OPENTXS_REPO "https://github.com/Open-Transactions/opentxs")
set(OPENTXS_COMMIT "16749c9aa484f7c7d9cfbc5af98dbbc356733741")
set(SOURCE_PATH "${DOWNLOADS}/opentxs.git")
set(OT_VERSION_STRING "1.177.0")

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
    "${OPENTXS_REPO}"
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
    "${OPENTXS_REPO}"
    "${SOURCE_PATH}"
  )
endif()

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps")

vcpkg_execute_in_download_mode(
  COMMAND
  "${GIT}"
  -C
  "${SOURCE_PATH}"
  reset
  --hard
  "${OPENTXS_COMMIT}"
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

if("qt5" IN_LIST FEATURES)
  set(OPENTXS_USE_QT5 ON)
  set(OPENTXS_QT_VERSION_MAJOR 5)
endif()

if("qt6" IN_LIST FEATURES)
  set(OPENTXS_USE_QT6 ON)
  set(OPENTXS_QT_VERSION_MAJOR 6)
endif()

set(OPENTXS_ENABLE_NONFREE OFF)
set(OPENTXS_ENABLE_MATTERFI OFF)

if("matterfi" IN_LIST FEATURES)
  set(OPENTXS_ENABLE_NONFREE ON)
  set(OPENTXS_ENABLE_MATTERFI ON)
endif()

if(OPENTXS_USE_QT5 AND OPENTXS_USE_QT6)
  message(FATAL_ERROR "Only one version of Qt must be enabled")
endif()

if(OPENTXS_USE_QT5 OR OPENTXS_USE_QT6)
  set(OPENTXS_USE_QT ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH
  "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
  -DOPENTXS_BUILD_TESTS=OFF
  -DOPENTXS_PEDANTIC_BUILD=OFF
  -DOT_CRYPTO_SUPPORTED_KEY_RSA=ON
  -DOT_CASH_USING_LUCRE=OFF
  -DOT_SCRIPT_USING_CHAI=OFF
  -DOT_WITH_QT=${OPENTXS_USE_QT}
  -DOT_WITH_QML=${OPENTXS_USE_QT}
  -DOT_ENABLE_NONFREE=${OPENTXS_ENABLE_NONFREE}
  -DOT_ENABLE_MATTERFI=${OPENTXS_ENABLE_MATTERFI}
  -DOT_USE_VCPKG_TARGETS=ON
  -DOT_BOOST_JSON_HEADER_ONLY=OFF
  -Dopentxs_GIT_VERSION=${OT_VERSION_STRING}
  OPTIONS_RELEASE
  -DOPENTXS_DEBUG_BUILD=OFF
  -DOT_LICENSE_FILE_NAME=copyright
  OPTIONS_DEBUG
  -DOPENTXS_DEBUG_BUILD=ON
  -DOT_INSTALL_HEADERS=OFF
  -DOT_INSTALL_LICENSE=OFF
  -DOT_HEADER_INSTALL_PATH=../include
  -DOT_CMAKE_INSTALL_PATH=${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake
)

vcpkg_cmake_install()
