require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

# Generales y Reaseguradoras => 10% - 20%
# 
# Generales: 2
# Generales-ART: 23
# Reaseguradora admitida: 8
# Reaseguradora local: 15
#
# ART => 5% - 20%
#
# ART: 4
#
# Vida y Retiro => 12% - 30%
#
# Vida: 1
# Retiro: 3

umbrales = [
  {id_tie_mes: 201303, id_com_actividad1:  2, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201303, id_com_actividad1: 23, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201303, id_com_actividad1:  8, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201303, id_com_actividad1: 15, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201303, id_com_actividad1:  4, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201303, id_com_actividad1:  1, i_umb_inversion_min:  5, i_umb_inversion_max: 30},
  {id_tie_mes: 201303, id_com_actividad1:  3, i_umb_inversion_min:  5, i_umb_inversion_max: 30},

  {id_tie_mes: 201304, id_com_actividad1:  2, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201304, id_com_actividad1: 23, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201304, id_com_actividad1:  8, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201304, id_com_actividad1: 15, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201304, id_com_actividad1:  4, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201304, id_com_actividad1:  1, i_umb_inversion_min:  5, i_umb_inversion_max: 30},
  {id_tie_mes: 201304, id_com_actividad1:  3, i_umb_inversion_min:  5, i_umb_inversion_max: 30},

  {id_tie_mes: 201305, id_com_actividad1:  2, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201305, id_com_actividad1: 23, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201305, id_com_actividad1:  8, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201305, id_com_actividad1: 15, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201305, id_com_actividad1:  4, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
  {id_tie_mes: 201305, id_com_actividad1:  1, i_umb_inversion_min:  5, i_umb_inversion_max: 30},
  {id_tie_mes: 201305, id_com_actividad1:  3, i_umb_inversion_min:  5, i_umb_inversion_max: 30}
]

meses = [201306, 201307, 201308, 201309, 201310, 201311, 201312]

(201401..201412).each do |mes|
  meses << mes
end

meses.each do |mes|
  umbrales.concat [ 
    {id_tie_mes: mes, id_com_actividad1:  2, i_umb_inversion_min: 10, i_umb_inversion_max: 20},
    {id_tie_mes: mes, id_com_actividad1: 23, i_umb_inversion_min: 10, i_umb_inversion_max: 20},
    {id_tie_mes: mes, id_com_actividad1:  8, i_umb_inversion_min: 10, i_umb_inversion_max: 20},
    {id_tie_mes: mes, id_com_actividad1: 15, i_umb_inversion_min: 10, i_umb_inversion_max: 20},
    {id_tie_mes: mes, id_com_actividad1:  4, i_umb_inversion_min:  5, i_umb_inversion_max: 20},
    {id_tie_mes: mes, id_com_actividad1:  1, i_umb_inversion_min: 12, i_umb_inversion_max: 30},
    {id_tie_mes: mes, id_com_actividad1:  3, i_umb_inversion_min: 12, i_umb_inversion_max: 30}
  ]
end

load umbrales, to: bases['panel'], table: 'ft_umbral_inciso_k', append: false
