require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

load [{id: 1, código: 'vacío', nombre: 'SIN REGISTRAR'}], to: bases['panel'], table: 'lk_com_segmentacion', append: false do
  field :id, map: 'id_com_segmentacion'
  field :código, map: 'cd_com_segmentacion'
  field :nombre, map: 'ds_com_segmentacion'
end
