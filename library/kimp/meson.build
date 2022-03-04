message('KIMP Runtime library')

kimp_sources = [
    'kimp/config.d',
    'kimp/i18n.d',
    'kimp/ini.d',
    'kimp/package.d',
    'kimp/password.d',
    'kimp/ver.d'
]

kimp_library = shared_library(
    'kimp',
    kimp_sources,
    install: true
)

kimp_dep = declare_dependency(
    link_with: kimp_library,
    include_directories: './'
)
