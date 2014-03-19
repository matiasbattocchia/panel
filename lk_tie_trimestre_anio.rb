require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

valores = [{id_tie_trimestre_anio: 1, ds_tie_trimestre_anio: 'Primero'},
           {id_tie_trimestre_anio: 2, ds_tie_trimestre_anio: 'Segundo'},
           {id_tie_trimestre_anio: 3, ds_tie_trimestre_anio: 'Tercero'},
           {id_tie_trimestre_anio: 4, ds_tie_trimestre_anio: 'Cuarto'}]

load valores, to: bases['panel'], table: 'lk_tie_trimestre_anio', append: false
