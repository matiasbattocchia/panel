require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

inversiones =
extract(from: bases['sinensup'], table: 'INV_INVERSIONES_RECIBIDAS_STOCK', exclude: true) do
  field 'id_com_compania', map: 'CIAID',
    type: Integer
  field 'id_tie_mes', map: 'periodo',
    type: Integer
  field 'id_ent_version_rectificativo', map: 'version_rectificativo'
  field 'id_inv_inversion', map: 'codigo_ssn',
    stripe: true
  field 'i_inv_valor_contable', map: 'valor_contable'
end

load inversiones, to: bases['panel'], table: 'ft_inversion', append: false
