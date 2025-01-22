from __future__ import division, print_function, absolute_import
from arc import *
from arc.divalent_atom_functions import DivalentAtom
from arc.wigner import Wigner3j, Wigner6j
from scipy.constants import physical_constants
from scipy.constants import Rydberg as C_Rydberg
from scipy.constants import m_e as C_m_e
from scipy.constants import c as C_c
from math import log

from typing import List, Tuple

import os
import numpy as np
import csv
from math import sqrt

from arc._database import sqlite3, UsedModulesARC

def getTransitionFrequencyLithium7(self, n1, l1, j1, n2, l2, j2, s=0.5, s2=None):
    if s2 is None:
        s2 = s
    if n1 == 2 and l1 == 0 and j1 == float(1/2) and n2 == 2 and l2 == 1 and j2 == float(1/2):
        freq = 446800129853000.0
    elif n1 == 2 and l1 == 1 and j1 == float(1/2) and n2 == 2 and l2 == 0 and j2 == float(1/2):
        freq = -446800129853000.0
    elif n1 == 2 and l1 == 0 and j1 == float(1/2) and n2 == 2 and l2 == 1 and j2 == float(3/2):
        freq = 446810183289000.0
    elif n1 == 2 and l1 == 1 and j1 == float(3/2) and n2 == 2 and l2 == 0 and j2 == float(1/2):
        freq = -446810183289000.0
    else:
        freq = (self.getEnergy(n2, l2, j2, s=s2) - self.getEnergy(n1, l1, j1, s=s)) * C_e / C_h
    return freq
def getLandegjExactEdit(self, l, j, s=0.5):
    if j == 0:
        return float(0)
    else:
        return self.gL * (j * (j + 1.0) - s * (s + 1.0) + l * (l + 1.0)) / (
            2.0 * j * (j + 1.0)
        ) + self.gS * (j * (j + 1.0) + s * (s + 1.0) - l * (l + 1.0)) / (
            2.0 * j * (j + 1.0)
        )
        
def getLandegfExactEdit(self, l, j, f, s=0.5):
    if f == 0:
        return float(0)
    else:
        gf = self.getLandegjExact(l, j, s) * (
            f * (f + 1) - self.I * (self.I + 1) + j * (j + 1.0)
        ) / (2 * f * (f + 1.0)) + self.gI * (
            f * (f + 1.0) + self.I * (self.I + 1.0) - j * (j + 1.0)
        ) / (
            2.0 * f * (f + 1.0)
        )
        return gf
AlkaliAtom.getLandegjExact = getLandegjExactEdit
AlkaliAtom.getLandegfExact = getLandegfExactEdit

class Lithium7(AlkaliAtom):  # Li
    """
    Properties of lithium 7 atoms
    """

    # ALL PARAMETERES ARE IN ATOMIC UNITS (HATREE)
    # model potential parameters from Marinescu et.al, PRA 49:982 (1994)
    alphaC = 0.1923
    """
        model potential parameters from [#c1]_

    """
    a1 = [2.47718079, 3.45414648, 2.51909839, 2.51909839]
    """
        model potential parameters from [#c1]_

    """
    a2 = [1.84150932, 2.55151080, 2.43712450, 2.43712450]
    """
        model potential parameters from [#c1]_

    """
    a3 = [-0.02169712, -0.21646561, 0.32505524, 0.32505524]
    """
        model potential parameters from [#c1]_

    """
    a4 = [-0.11988362, -0.06990078, 0.10602430, 0.10602430]
    """
        model potential parameters from [#c1]_

    """
    rc = [0.61340824, 0.61566441, 2.34126273, 2.34126273]
    """
        model potential parameters from [#c1]_

    """

    Z = 3

    I = 1.5  # 3/2

    NISTdataLevels = 42
    ionisationEnergy = 5.391719  #: (eV) NIST Ref. [#c11]_.
    gI = -0.0011822130;
    quantumDefect = [
        [
            [0.3995101, 0.0290, 0.0, 0.0, 0.0, 0.0],
            [0.0471780, -0.024, 0.0, 0.0, 0.0, 0.0],
            [0.002129, -0.01491, 0.1759, -0.8507, 0.0, 0.0],
            [-0.000077, 0.021856, -0.4211, 2.3891, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
        [
            [0.3995101, 0.0290, 0.0, 0.0, 0.0, 0.0],
            [0.0471665, -0.024, 0.0, 0.0, 0.0, 0.0],
            [0.002129, -0.01491, 0.1759, -0.8507, 0.0, 0.0],
            [-0.000077, 0.021856, -0.4211, 2.3891, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
    ]
    """
        quantum defects for :math:`nS` and :math:`nP` states are
        from Ref. [#c6]_. Quantum defects for :math:`D_j` and :math:`F_j`
        states are from [#c7]_.

    """

    levelDataFromNIST = "li_NIST_level_data.ascii"
    dipoleMatrixElementFile = "li7_dipole_matrix_elements.npy"
    quadrupoleMatrixElementFile = "li7_quadrupole_matrix_elements.npy"

    minQuantumDefectN = 4

    precalculatedDB = "li7_precalculated.db"
    literatureDMEfilename = 'lithium7_literature_dme.csv'
    # levels that are for smaller n than ground level,
    # but are above in energy due to angular part
    extraLevels = []

    groundStateN = 2

    #: source NIST, Atomic Weights and Isotopic Compositions [#c14]_
    mass = 7.0160034366 * physical_constants["atomic mass constant"][0]
    #: source NIST, Atomic Weights and Isotopic Compositions [#c14]_
    abundance = 0.9241

    gL = 1 - physical_constants["electron mass"][0] / mass

    scaledRydbergConstant = (
        (mass - C_m_e)
        / (mass)
        * C_Rydberg
        * physical_constants["inverse meter-electron volt relationship"][0]
    )

    elementName = "Li7"
    meltingPoint = 180.54 + 273.15  #: in K

    #: source of HFS magnetic dipole and quadrupole constants
    hyperfineStructureData = "li7_hfs_data.csv"

    def getPressure(self, temperature):
        """
        Pressure of atomic vapour at given temperature (in K).

        Uses equation and values from [#c3]_. Values from table 3.
        (accuracy +-1 %) are used for both liquid and solid phase of Li.

        """

        if temperature < self.meltingPoint:
            # Li is in solid phase (from table 3. of the cited reference
            # "precisely fitted equations / +- 1%)
            return (
                10.0
                ** (
                    2.881
                    + 7.790
                    - 8423.0 / temperature
                    - 0.7074 * log(temperature) / log(10.0)
                )
                * 133.322368
            )

        elif temperature < 1000.0 + 273.15:
            # Li is in liquid phase (from table 3. of the cited reference
            # "precisely fitted equations / +- 1%)
            return (
                10.0
                ** (
                    2.881
                    + 8.409
                    - 8320.0 / temperature
                    - 1.0255 * log(temperature) / log(10.0)
                )
                * 133.322368
            )
        else:
            print(
                "ERROR: Li vapour pressure above 1000 C is unknown \
                    (limits of experimental interpolation)"
            )
            return 0
Lithium7.getTransitionFrequency = getTransitionFrequencyLithium7        

class Strontium84(DivalentAtom):
    """
    Properties of Strontium 84 atoms
    """

    alphaC = 15

    ionisationEnergy = 1377012721e6 * C_h / C_e  #: (eV)  Ref. [#c10]_

    Z = 38
    I = 0.0

    #: Ref. [#c10]_
    scaledRydbergConstant = (
        109736.631
        * 1.0e2
        * physical_constants["inverse meter-electron volt relationship"][0]
    )

    quantumDefect = [
        [
            [3.269123, -0.177769, 3.4619, 0.0, 0.0, 0.0],
            [2.72415, -3.390, -220.0, 0.0, 0.0, 0.0],
            [2.384667, -42.03053, -619.0, 0.0, 0.0, 0.0],
            [0.090886, -2.4425, 61.896, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
        [
            [3.3707725, 0.41979, -0.421377, 0.0, 0.0, 0.0],
            [2.88673, 0.433745, -1.800, 0.0, 0.0, 0.0],
            [2.675236, -13.23217, -4418.0, 0.0, 0.0, 0.0],
            [0.120588, -2.1847, 102.98, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
        [
            [3.3707725, 0.41979, -0.421377, 0.0, 0.0, 0.0],
            [2.88265, 0.39398, -1.1199, 0.0, 0.0, 0.0],
            [2.661488, -16.8524, -6629.26, 0.0, 0.0, 0.0],
            [0.11899, -2.0446, 103.26, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
        [
            [3.3707725, 0.41979, -0.421377, 0.0, 0.0, 0.0],
            [2.88163, -2.462, 145.18, 0.0, 0.0, 0.0],
            [2.655, -65.317, -13576.7, 0.0, 0.0, 0.0],
            [0.12000, -2.37716, 118.97, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
    ]
    """ Contains list of modified Rydberg-Ritz coefficients for calculating
        quantum defects for
        [[ :math:`^1S_{0},^1P_{1},^1D_{2},^1F_{3}`],
        [ :math:`^3S_{1},^3P_{0},^3D_{1},^3F_{2}`],
        [ :math:`^3S_{1},^3P_{1},^3D_{2},^3F_{3}`],
        [ :math:`^3S_{1},^3P_{2},^3D_{3},^3F_{4}`]]."""

    groundStateN = 5

    # levels that are for smaller n than ground level, but are above in energy
    # due to angular part
    extraLevels = [
        (4, 2, 3, 1),
        (4, 2, 1, 1),
        (4, 3, 3, 0),
        (4, 3, 4, 1),
        (4, 3, 3, 1),
        (4, 3, 2, 1),
        (4, 2, 2, 0),
    ]

    #: Sources Refs. [#c1]_, [#c2]_, [#c3]_, [#c4]_, [#c5]_, [#c6]_, [#c7]_,
    #: [#c8]_ , [#c10]_
    levelDataFromNIST = "sr_level_data.csv"

    precalculatedDB = "sr88_precalculated.db"
    dipoleMatrixElementFile = "sr_dipole_matrix_elements.npy"
    quadrupoleMatrixElementFile = "sr_quadrupole_matrix_elements.npy"

    literatureDMEfilename = "strontium_literature_dme.csv"

    elementName = "Sr84"
    meltingPoint = 777 + 273.15  #: in K

    #: Ref. [#nist]_
    mass = 83.913425 * physical_constants["atomic mass constant"][0]

    #: Quantum defect principal quantum number fitting ranges for different
    #: series
    defectFittingRange = {
        "1S0": [14, 34],
        "3S1": [15, 50],
        "1P1": [10, 29],
        "3P2": [19, 41],
        "3P1": [8, 21],
        "3P0": [8, 15],
        "1D2": [20, 50],
        "3D3": [20, 37],
        "3D2": [28, 50],
        "3D1": [28, 50],
        "1F3": [10, 28],
        "3F4": [10, 28],
        "3F3": [10, 24],
        "3F2": [10, 24],
    }

    def getPressure(self, temperature):
        """
        Pressure of atomic vapour at given temperature.

        Calculates pressure based on Ref. [#pr]_ (accuracy +- 5%).
        """
        if temperature < 298:
            print("WARNING: Sr vapour pressure below 298 K is unknown (small)")
            return 0
        if temperature < self.meltingPoint:
            return 10 ** (
                5.006
                + 9.226
                - 8572 / temperature
                - 1.1926 * log(temperature) / log(10.0)
            )
        else:
            raise ValueError(
                "ERROR: Sr vapour pressure above %.0f C is unknown"
                % self.meltingPoint
            )

def readLiteratureValuesEdit(self):
    # clear previously saved results, since literature file
    # might have been updated in the meantime
    c = self.conn.cursor()
    c.execute("""DROP TABLE IF EXISTS literatureDME""")
    c.execute(
        """SELECT COUNT(*) FROM sqlite_master
                    WHERE type='table' AND name='literatureDME';"""
    )
    if c.fetchone()[0] == 0:
        # create table
        c.execute(
            """CREATE TABLE IF NOT EXISTS literatureDME
         (n1 TINYINT UNSIGNED, l1 TINYINT UNSIGNED, j1 TINYINT UNSIGNED,
         n2 TINYINT UNSIGNED, l2 TINYINT UNSIGNED, j2 TINYINT UNSIGNED,
         s TINYINT UNSIGNED,
         dme DOUBLE,
         typeOfSource TINYINT,
         errorEstimate DOUBLE,
         comment TINYTEXT,
         ref TINYTEXT,
         refdoi TINYTEXT
        );"""
        )
        c.execute(
            """CREATE INDEX compositeIndex
        ON literatureDME (n1,l1,j1,n2,l2,j2,s); """
        )
    self.conn.commit()

    if self.literatureDMEfilename == "":
        return 0  # no file specified for literature values

    try:
        fn = open(
            os.path.join(self.dataFolder, self.literatureDMEfilename), "r"
        )
        dialect = csv.Sniffer().sniff(fn.read(2024), delimiters=";,\t")
        fn.seek(0)
        data = csv.reader(fn, dialect, quotechar='"')

        literatureDME = []

        # i=0 is header
        i = 0
        for row in data:
            if i != 0:
                n1 = int(row[0])
                l1 = int(row[1])
                j1 = int(row[2])
                s1 = int(row[3])

                n2 = int(row[4])
                l2 = int(row[5])
                j2 = int(row[6])
                s2 = int(row[7])
                if s1 != s2:
                    raise ValueError(
                        "Error reading litearture: database "
                        "cannot accept spin changing "
                        "transitions"
                    )
                s = s1
                if self.getEnergy(n1, l1, j1, s=s) > self.getEnergy(
                    n2, l2, j2, s=s
                ):
                    temp = n1
                    n1 = n2
                    n2 = temp
                    temp = l1
                    l1 = l2
                    l2 = temp
                    temp = j1
                    j1 = j2
                    j2 = temp

                # convered from reduced DME in J basis (symmetric notation)
                # to radial part of dme as it is saved for calculated
                # values

                # To-DO : see in what notation are Strontium literature elements saved
                #print(
                #    "To-do (_readLiteratureValues): see in what notation are Sr literature saved (angular part)"
                #)
                dme = float(row[8]) / (
                    (-1) ** (round(l1 + s + j2 + 1.0))
                    * sqrt((2.0 * j1 + 1.0) * (2.0 * j2 + 1.0))
                    * Wigner6j(j1, 1.0, j2, l2, s, l1)
                    * (-1) ** l1
                    * sqrt((2.0 * l1 + 1.0) * (2.0 * l2 + 1.0))
                    * Wigner3j(l1, 1, l2, 0, 0, 0)
                )

                comment = row[9]
                typeOfSource = int(row[10])  # 0 = experiment; 1 = theory
                errorEstimate = float(row[11])
                ref = row[12]
                refdoi = row[13]

                literatureDME.append(
                    [
                        n1,
                        l1,
                        j1,
                        n2,
                        l2,
                        j2,
                        s,
                        dme,
                        typeOfSource,
                        errorEstimate,
                        comment,
                        ref,
                        refdoi,
                    ]
                )
            i += 1
        fn.close()

        try:
            if i > 1:
                c.executemany(
                    """INSERT INTO literatureDME
                                    VALUES (?,?,?,?,?,?,?,
                                            ?,?,?,?,?,?)""",
                    literatureDME,
                )
                self.conn.commit()

        except sqlite3.Error as e:
            print(
                "Error while loading precalculated values "
                "into the database"
            )
            print(e)
            print(literatureDME)
            exit()

    except IOError as e:
        print(
            "Error reading literature values File "
            + self.literatureDMEfilename
        )
        print(e)
DivalentAtom._readLiteratureValues = readLiteratureValuesEdit