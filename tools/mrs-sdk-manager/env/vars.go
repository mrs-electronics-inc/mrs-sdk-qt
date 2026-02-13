package env

type EnvVarType int

const (
	FilePath EnvVarType = iota
	DirPath
)

type EnvVar struct {
	Key         string
	Description string
	Type        EnvVarType
}

// These are all of the valid environment variables for mrs-sdk-manager.
var (
	YOCTO_QT5_SYSROOT = EnvVar{
		Key:         "YOCTO_QT5_SYSROOT",
		Description: "Path to the Yocto Qt5 sysroot",
		Type:        DirPath,
	}
	YOCTO_QT5_CXX_COMPILER = EnvVar{
		Key:         "YOCTO_QT5_CXX_COMPILER",
		Description: "Path to the Yocto Qt5 C++ cross-compiler",
		Type:        FilePath,
	}
	YOCTO_QT5_ENV_SETUP_SCRIPT = EnvVar{
		Key:         "YOCTO_QT5_ENV_SETUP_SCRIPT",
		Description: "Path to the Yocto Qt5 environment setup script",
		Type:        FilePath,
	}
	BUILDROOT_QT5_SYSROOT = EnvVar{
		Key:         "BUILDROOT_QT5_SYSROOT",
		Description: "Path to the Buildroot Qt5 sysroot",
		Type:        DirPath,
	}
	BUILDROOT_QT5_CXX_COMPILER = EnvVar{
		Key:         "BUILDROOT_QT5_CXX_COMPILER",
		Description: "Path to the Buildroot Qt5 C++ cross-compiler",
		Type:        FilePath,
	}
	DESKTOP_CXX_COMPILER = EnvVar{
		Key:         "DESKTOP_CXX_COMPILER",
		Description: "Path to the desktop C++ compiler",
		Type:        FilePath,
	}
	DESKTOP_QT5_PREFIX = EnvVar{
		Key:         "DESKTOP_QT5_PREFIX",
		Description: "Path to the desktop Qt5 installation",
		Type:        DirPath,
	}
	DESKTOP_QT6_PREFIX = EnvVar{
		Key:         "DESKTOP_QT6_PREFIX",
		Description: "Path to the desktop Qt6 installation",
		Type:        DirPath,
	}
)
var allVars = []EnvVar{
	YOCTO_QT5_SYSROOT,
	YOCTO_QT5_CXX_COMPILER,
	YOCTO_QT5_ENV_SETUP_SCRIPT,
	BUILDROOT_QT5_SYSROOT,
	BUILDROOT_QT5_CXX_COMPILER,
	DESKTOP_CXX_COMPILER,
	DESKTOP_QT5_PREFIX,
	DESKTOP_QT6_PREFIX,
}

// These are different data representations of the env variables.
var ValidEnvKeys = []string{}
var EnvVarsMetadataMap = map[string]EnvVar{}

func init() {
	for _, v := range allVars {
		ValidEnvKeys = append(ValidEnvKeys, v.Key)
		EnvVarsMetadataMap[v.Key] = v
	}
}
