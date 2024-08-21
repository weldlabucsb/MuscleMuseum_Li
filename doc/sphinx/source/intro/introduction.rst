Introduction
==========================
**MuscleMuseum** is a object-oriented MATLAB toolbox designed for Atomic, Molecular, and Optical
(AMO) physics. It serves as an integrated solution for experimental control,
data management, data analysis, and numerical simulation. The toolbox has
several key features:

#. Direct Hardware Control: Leveraging MATLAB's rich set of hardware communication toolboxes, such as the `Data Acquisition Toolbox <https://www.mathworks.com/products/data-acquisition.html>`_, MuscleMuseum provides seamless integration for automatic hardware control.
#. Data Management with `PostgreSQL <https://www.postgresql.org/>`_: MuscleMuseum employs the robust PostgreSQL database system for efficient data management. This ensures reliable storage and retrieval of experimental data.
#. User-Friendly GUIs: The package offers intuitive Graphical User Interfaces (GUIs) developed using `MATLAB App Designer <https://www.mathworks.com/products/matlab/app-designer.html>`_.

Right now, I have implemented:

#. A BEC experimental control and data analysis system integrated with `Cicero <https://akeshet.github.io/Cicero-Word-Generator/>`_ (the BecExp class) 
#. Apps for controlling and browsing BEC experiments (BecControlPanel and BecBrowser)
#. Atomic data and atomic structure handling (the Atom class)
#. A single-atom master equation simulation tool (the MeSim class)
#. A 1D Time-dependent Schrodinger equation (TDSE) simulation tool (the SeSim1D class)
#. A 1D lattice dynamics simulation tool (the LatticeSeSim1D class)
#. Some lattice band structure calculations (the OpticalLattice class)
#. Keysight function generator control

Still under construction:

#. Gross-Pitaevskii equation simulation
#. Scope talk
#. RF generator control

Known issues: the database functions I wrote are not compatible with MATLAB 2023b or higher. I
need to fix this in the future. The database may not be accessed through VPN
for now.