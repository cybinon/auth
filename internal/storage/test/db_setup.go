package test

import (
	"github.com/cybinon/auth/internal/conf"
	"github.com/cybinon/auth/internal/storage"
)

func SetupDBConnection(globalConfig *conf.GlobalConfiguration) (*storage.Connection, error) {
	return storage.Dial(globalConfig)
}
