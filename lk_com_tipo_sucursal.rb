require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
[{id_com_tipo_sucursal: 1, ds_com_tipo_sucursal: 'Casa matriz'},
 {id_com_tipo_sucursal: 2, ds_com_tipo_sucursal: 'Sucursal'   },
 {id_com_tipo_sucursal: 3, ds_com_tipo_sucursal: 'Agencia'    }]

datos =
transform datos do
  new_field 'cd_com_tipo_sucursal', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_com_tipo_sucursal', append: false
