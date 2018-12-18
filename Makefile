TARGS = salt_restore_PHC2.720x576.v20180405.nc
DEPS = ocean_hgrid.nc ocean_mask.nc PHC2_salx.2004_08_03.nc PHC2_salx.2004_08_03.corrected.nc

all: $(TARGS) hash.md5
	md5sum -c hash.md5

ocean_hgrid.nc ocean_mask.nc:
	wget -nv ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/OM4_05/$@
	md5sum -c $@.md5
PHC2_salx.2004_08_03.nc:
	wget -nv http://data1.gfdl.noaa.gov/~nnz/mom4/COREv1/support_data/PHC2_salx.2004_08_03.nc
	md5sum -c $@.md5
PHC2_salx.2004_08_03.corrected.nc: PHC2_salx.2004_08_03.nc
	ncap2 -h -O -s 'time(:)={15,45,76,106,136,168,198,228,258,288,320,350}' $< $@
	ncatted -h -O -a units,time,o,c,'days since 1900-01-01 00:00:00' $@
	ncatted -h -O -a long_name,time,o,c,'Day of year' $@
	ncatted -h -O -a calendar,time,c,c,'julian' $@
	ncatted -h -O -a modulo,time,c,c,' ' $@
	ncatted -h -O -a calendar_type,time,c,c,'julian' $@
	md5sum -c $@.md5

salt_restore_PHC2.720x576.v20180405.nc: PHC2_salx.2004_08_03.corrected.nc ocean_hgrid.nc ocean_mask.nc
	./interp_and_fill/interp_and_fill.py ocean_hgrid.nc ocean_mask.nc PHC2_salx.2004_08_03.corrected.nc SALT --fms --closest $@

hash.md5: | $(TARGS)
	md5sum $(TARGS) > $@

clean:
	rm -f $(TARGS) $(DEPS) pickle.*
