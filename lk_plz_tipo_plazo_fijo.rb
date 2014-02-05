require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

tipos =
extract(from: bases['sinensup'], table: 'TIPOS_DEPOSITO', exclude: true) do
  field 'ds_plz_tipo_plazo_fijo', map: 'descripcion',
    strip: true
  field 'id_plz_tipo_plazo_fijo', map: 'ID',
    type: Integer
end

load tipos, to: bases['panel'], table: 'lk_plz_tipo_plazo_fijo', append: false
