use ExtUtils::MakeMaker;

WriteMakefile(
  PREREQ_PM => {
    'Path::Class' => 0,
    'Class::Accessor::Fast' => 0,
    'Test::More' => 0.88,
    'Test::Output' => 0,
  },
);
