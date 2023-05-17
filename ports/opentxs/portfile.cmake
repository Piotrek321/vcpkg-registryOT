set(OPENTXS_REPO "https://github.com/Open-Transactions/opentxs")
set(OPENTXS_COMMIT "705235dd809143a282258ff506e7dac469bdf6c9")
set(SOURCE_PATH "${DOWNLOADS}/opentxs.git")

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
  -DOT_USE_VCPKG_TARGETS=ON
  -DOT_BOOST_JSON_HEADER_ONLY=OFF
  -DQT_VERSION_MAJOR=${OPENTXS_QT_VERSION_MAJOR}
  OPTIONS_RELEASE
  -DOPENTXS_DEBUG_BUILD=OFF
  OPTIONS_DEBUG
  -DOPENTXS_DEBUG_BUILD=ON
)

vcpkg_cmake_install()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
