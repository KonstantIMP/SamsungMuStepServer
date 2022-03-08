message('Configure the server app')

mu_step_sources = [
    'app.d',
    
    'mustep/defines.d',

    'mustep/config.d',
    'mustep/config_instance.d',

    'mustep/server.d',

    'mustep/api/impl.d',
    'mustep/api/base.d'
]

mu_step_binary = executable(
    'mustep',
    mu_step_sources,
    dependencies: [
        vibed_deps,
        kimp_dep,
        sqlite_deps
    ],
    install: true,
    d_args: ['-J=../views/']
)
