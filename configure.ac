# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([niem-release-model], [0], [wr@gatech.edu])
AC_COPYRIGHT

# Checks for programs.
AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_SED

dnl WR_check_prog( $command-name )
dnl   e.g., WR_check_prog(bash) will set @bash@
AC_DEFUN([WR_check_prog],[AC_PATH_PROG($1,$1)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

dnl WR_check_prog_options( $command-short-name, $command-name-options ... )
dnl   e.g., WR_check_prog_options(cat, gcat cat) will set @cat@
AC_DEFUN([WR_check_prog_options],[AC_PATH_PROGS($1,$2)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

# Only put critical programs required to build 'all' here.  Additional
# validations can pull things from $PATH.

# unix stuff
WR_check_prog(bash)
WR_check_prog_options(find,gfind find)

# webb stuff
WR_check_prog(saxon)

default_output_dir=${srcdir}/../publish
if test "x$output_dir" = "x"
then AC_MSG_NOTICE([Variable output_dir not set. Using default ($default_output_dir)])
  output_dir=$default_output_dir
else AC_MSG_RESULT([output_dir set to ${output_dir}])
     AC_SUBST([output_dir],[$output_dir])
     if ! test -d "${output_dir}"
     then AC_MSG_WARN([output_dir ${output_dir} does not exist])
     fi
fi

default_xml_catalog=${srcdir}/../../distro/niem/xml-catalog.xml
if test "x$xml_catalog" = "x"
then AC_MSG_NOTICE([Variable xml_catalog not set. Using default ($default_xml_catalog)])
  xml_catalog=$default_xml_catalog
else AC_MSG_RESULT([xml_catalog set to ${xml_catalog}])
     AC_SUBST([xml_catalog],[$xml_catalog])
     if ! test -f "${xml_catalog}"
     then AC_MSG_ERROR([xml_catalog ${xml_catalog} does not exist])
     fi
fi

AC_CONFIG_FILES([Makefile], [chmod 444 Makefile])
AC_OUTPUT
