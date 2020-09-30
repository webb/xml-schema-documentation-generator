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
WR_check_prog_options(touch,gtouch touch)

# webb stuff
WR_check_prog(saxon)

if test "x$publish_dir" = "x"
then AC_MSG_ERROR([Variable publish_dir not set; set it to the folder of the published model website.])
else AC_MSG_RESULT([publish_dir set to ${publish_dir}])
     AC_SUBST([publish_dir],[$publish_dir])
     if ! test -d "${publish_dir}"
     then AC_MSG_WARN([publish_dir ${publish_dir} does not exist])
     fi
fi

if test "x$xml_catalog" = "x"
then AC_MSG_ERROR([Variable xml_catalog not set; set it to the root XML catalog of your data model.])
else
  if ! test -f "${xml_catalog}"
  then AC_MSG_ERROR([File xml_catalog=${xml_catalog} does not exist.])
  else
    AC_MSG_RESULT([xml_catalog set to ${xml_catalog}])
    AC_SUBST([xml_catalog],[$xml_catalog])
  fi
fi

default_build_json=false
if test "x$build_json" = "x"
then AC_MSG_NOTICE([Variable build_json not set. Using default ($default_build_json)])
     build_json=$default_build_json
elif test \( "$build_json" = true \) -o \( "$build_json" = false \)
then AC_MSG_RESULT([build_json set to ${build_json}])
     AC_SUBST([build_json],[$build_json])
else AC_MSG_ERROR([\$build_json should be true or false (got $build_json)])
fi

default_link_to_dirs=false
if test "x$link_to_dirs" = "x"
then AC_MSG_NOTICE([Variable link_to_dirs not set. Using default ($default_link_to_dirs)])
     link_to_dirs=$default_link_to_dirs
elif test \( "$link_to_dirs" = true \) -o \( "$link_to_dirs" = false \)
then AC_MSG_RESULT([link_to_dirs set to ${link_to_dirs}])
     AC_SUBST([link_to_dirs],[$link_to_dirs])
else AC_MSG_ERROR([\$link_to_dirs should be true or false (got $link_to_dirs)])
fi

AC_CONFIG_FILES([Makefile], [chmod 444 Makefile])
AC_CONFIG_FILES([run], [chmod 555 run])
AC_OUTPUT
